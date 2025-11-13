import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/features/team/data/team_service.dart';
import 'package:iosmobileapp/features/team/domain/worker.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_bloc.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_event.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_state.dart';
import 'package:iosmobileapp/features/team/presentation/widgets/empty_team_placeholder.dart';
import 'package:iosmobileapp/features/team/presentation/widgets/worker_card.dart';

import 'worker_form_page.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          WorkersBloc(service: TeamService())..add(const LoadWorkers()),
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
      appBar: AppBar(title: const Text('Equipo')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateWorker(context),
        icon: const Icon(Icons.add),
        label: const Text('Agregar miembro'),
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
                        onEdit: () => _openEditWorker(context, worker),
                        onDelete: () => _confirmDelete(context, worker),
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

  void _openCreateWorker(BuildContext context) {
    final bloc = context.read<WorkersBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: bloc, child: const WorkerFormPage()),
      ),
    );
  }

  void _openEditWorker(BuildContext context, Worker worker) {
    final bloc = context.read<WorkersBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: WorkerFormPage(initialWorker: worker),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Worker worker) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar miembro'),
        content: Text('¿Deseas eliminar a ${worker.name}?'),
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
      context.read<WorkersBloc>().add(
        DeleteWorkerRequested(workerId: worker.id),
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
