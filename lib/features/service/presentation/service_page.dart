import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/features/service/data/services_service.dart';
import 'package:iosmobileapp/features/service/domain/service.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_bloc.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_event.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_state.dart';
import 'package:iosmobileapp/features/service/presentation/widgets/empty_service_placeholder.dart';
import 'package:iosmobileapp/features/service/presentation/widgets/service_card.dart';

import 'service_form_page.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ServicesBloc(service: ServicesService())..add(const LoadServices()),
      child: Builder(builder: (context) => const _ServiceView()),
    );
  }
}

class _ServiceView extends StatelessWidget {
  const _ServiceView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servicios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateService(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo servicio'),
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
                      final isDeleting = state.deletingServiceId == service.id;
                      return ServiceCard(
                        service: service,
                        onEdit: () => _openEditService(context, service),
                        onDelete: () => _confirmDelete(context, service),
                        isDeleting: isDeleting,
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

  void _openEditService(BuildContext context, Service service) {
    final bloc = context.read<ServicesBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: ServiceFormPage(initialService: service),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Service service) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar servicio'),
        content: Text('¿Eliminar el servicio "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      context.read<ServicesBloc>().add(
        DeleteServiceRequested(serviceId: service.id),
      );
    }
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
