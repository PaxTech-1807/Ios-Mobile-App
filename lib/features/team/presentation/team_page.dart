import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/core/services/onboarding_service.dart';
import 'package:iosmobileapp/features/team/data/team_service.dart';
import 'package:iosmobileapp/features/team/domain/worker.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_bloc.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_event.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_state.dart';
import 'package:iosmobileapp/features/team/presentation/widgets/empty_team_placeholder.dart';
import 'package:iosmobileapp/features/team/presentation/widgets/worker_card.dart';
import 'package:iosmobileapp/features/team/presentation/widgets/worker_modal.dart';

import 'worker_form_page.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final _onboardingService = OnboardingService();
  TeamService? _service;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    // No necesitamos pasar el token, el servicio lo obtiene automáticamente
    if (mounted) {
      setState(() {
        _service = TeamService();
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
          WorkersBloc(service: _service!)..add(const LoadWorkers()),
      child: Builder(
        builder: (context) {
          return const _TeamView();
        },
      ),
    );
  }
}

class _TeamView extends StatelessWidget {
  const _TeamView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trabajadores',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateWorker(context),
        backgroundColor: const Color(0xFF7209B7),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: BlocListener<WorkersBloc, WorkersState>(
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
        child: BlocBuilder<WorkersBloc, WorkersState>(
          builder: (context, state) {
            switch (state.status) {
              case WorkersStatus.initial:
              case WorkersStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case WorkersStatus.failure:
                return _ErrorState(
                  message: state.errorMessage ?? 'Error desconocido',
                  onRetry: () =>
                      context.read<WorkersBloc>().add(const LoadWorkers()),
                );
              case WorkersStatus.success:
                if (state.workers.isEmpty) {
                  return EmptyTeamPlaceholder(
                    onAddPressed: () => _openCreateWorker(context),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<WorkersBloc>().add(const RefreshWorkers());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: state.workers.length,
                    itemBuilder: (context, index) {
                      final worker = state.workers[index];
                      final isDeleting = state.deletingWorkerId == worker.id;
                      return WorkerCard(
                        worker: worker,
                        onTap: () => _openWorkerModal(context, worker, isDeleting),
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

  void _openCreateWorker(BuildContext context) {
    final bloc = context.read<WorkersBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: bloc, child: const WorkerFormPage()),
      ),
    );
  }

  void _openWorkerModal(BuildContext context, Worker worker, bool isDeleting) {
    final bloc = context.read<WorkersBloc>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: bloc,
        child: WorkerModal(worker: worker, isDeleting: isDeleting),
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
