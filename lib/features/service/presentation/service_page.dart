import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/core/services/onboarding_service.dart';
import 'package:iosmobileapp/features/service/data/services_service.dart';
import 'package:iosmobileapp/features/service/domain/service.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_bloc.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_event.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_state.dart';
import 'package:iosmobileapp/features/service/presentation/widgets/empty_service_placeholder.dart';
import 'package:iosmobileapp/features/service/presentation/widgets/service_card.dart';
import 'package:iosmobileapp/features/service/presentation/widgets/service_modal.dart';

import 'service_form_page.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final _onboardingService = OnboardingService();
  ServicesService? _service;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    final token = await _onboardingService.getJwtToken();
    if (mounted) {
      setState(() {
        _service = ServicesService(authToken: token);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_service == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider(
      create: (_) =>
          ServicesBloc(service: _service!)..add(const LoadServices()),
      child: Builder(builder: (context) => const _ServiceView()),
    );
  }
}

class _ServiceView extends StatelessWidget {
  const _ServiceView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Servicios',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateService(context),
        backgroundColor: const Color(0xFF7209B7),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: BlocListener<ServicesBloc, ServicesState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          final message = state.errorMessage;
          if (message != null && message.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
        child: BlocBuilder<ServicesBloc, ServicesState>(
          builder: (context, state) {
            switch (state.status) {
              case ServicesStatus.initial:
              case ServicesStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case ServicesStatus.failure:
                return _ErrorState(
                  message: state.errorMessage ?? 'Error desconocido',
                  onRetry: () =>
                      context.read<ServicesBloc>().add(const LoadServices()),
                );
              case ServicesStatus.success:
                if (state.services.isEmpty) {
                  return EmptyServicePlaceholder(
                    onAddPressed: () => _openCreateService(context),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ServicesBloc>().add(const RefreshServices());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: state.services.length,
                    itemBuilder: (context, index) {
                      final service = state.services[index];
                      return ServiceCard(
                        service: service,
                        onTap: () => _openServiceModal(context, service),
                      );
                    },
                  ),
                );
            }
          },
        ),
      ),
    );
  }

  void _openCreateService(BuildContext context) {
    final bloc = context.read<ServicesBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: bloc, child: const ServiceFormPage()),
      ),
    );
  }

  void _openServiceModal(BuildContext context, Service service) {
    final bloc = context.read<ServicesBloc>();
    final state = context.read<ServicesBloc>().state;
    final isDeleting = state.deletingServiceId == service.id;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: bloc,
        child: ServiceModal(service: service, isDeleting: isDeleting),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
