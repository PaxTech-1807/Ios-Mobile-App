import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/core/services/onboarding_service.dart';
import 'package:iosmobileapp/features/auth/data/auth_service.dart';
import 'package:iosmobileapp/features/team/data/team_service.dart';
import 'package:iosmobileapp/features/team/domain/worker.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_event.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_state.dart';

class WorkersBloc extends Bloc<WorkersEvent, WorkersState> {
  WorkersBloc({
    required TeamService service,
    AuthService? authService,
    OnboardingService? onboardingService,
  })  : _service = service,
        _authService = authService ?? AuthService(),
        _onboardingService = onboardingService ?? OnboardingService(),
        super(const WorkersState()) {
    on<LoadWorkers>(_onLoadWorkers);
    on<RefreshWorkers>(_onRefreshWorkers);
    on<CreateWorkerRequested>(_onCreateWorkerRequested);
    on<UpdateWorkerRequested>(_onUpdateWorkerRequested);
    on<DeleteWorkerRequested>(_onDeleteWorkerRequested);
    on<WorkerFormReset>(_onWorkerFormReset);
  }

  final TeamService _service;
  final AuthService _authService;
  final OnboardingService _onboardingService;

  Future<void> _onLoadWorkers(
    LoadWorkers event,
    Emitter<WorkersState> emit,
  ) async {
    await _fetchWorkers(emit, setLoading: true);
  }

  Future<void> _onRefreshWorkers(
    RefreshWorkers event,
    Emitter<WorkersState> emit,
  ) async {
    await _fetchWorkers(emit, setLoading: false);
  }

  Future<void> _onCreateWorkerRequested(
    CreateWorkerRequested event,
    Emitter<WorkersState> emit,
  ) async {
    emit(
      state.copyWith(
        formStatus: WorkerFormStatus.submitting,
        formErrorMessage: null,
      ),
    );

    try {
      final Worker worker = await _service.createWorker(event.request);
      final List<Worker> updatedWorkers = List<Worker>.from(state.workers)
        ..add(worker);
      updatedWorkers.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      emit(
        state.copyWith(
          workers: updatedWorkers,
          formStatus: WorkerFormStatus.success,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          formStatus: WorkerFormStatus.failure,
          formErrorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateWorkerRequested(
    UpdateWorkerRequested event,
    Emitter<WorkersState> emit,
  ) async {
    emit(
      state.copyWith(
        formStatus: WorkerFormStatus.submitting,
        formErrorMessage: null,
      ),
    );

    try {
      final Worker worker = await _service.updateWorker(
        workerId: event.workerId,
        request: event.request,
      );
      final List<Worker> updatedWorkers =
          state.workers
              .map((existing) => existing.id == worker.id ? worker : existing)
              .toList()
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );

      emit(
        state.copyWith(
          workers: updatedWorkers,
          formStatus: WorkerFormStatus.success,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          formStatus: WorkerFormStatus.failure,
          formErrorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteWorkerRequested(
    DeleteWorkerRequested event,
    Emitter<WorkersState> emit,
  ) async {
    emit(state.copyWith(deletingWorkerId: event.workerId, errorMessage: null));

    try {
      await _service.deleteWorker(event.workerId);
      final List<Worker> updatedWorkers = state.workers
          .where((worker) => worker.id != event.workerId)
          .toList();
      emit(state.copyWith(workers: updatedWorkers, deletingWorkerId: null));
    } catch (error) {
      emit(
        state.copyWith(errorMessage: error.toString(), deletingWorkerId: null),
      );
    }
  }

  void _onWorkerFormReset(WorkerFormReset event, Emitter<WorkersState> emit) {
    emit(
      state.copyWith(formStatus: WorkerFormStatus.idle, formErrorMessage: null),
    );
  }

  Future<void> _fetchWorkers(
    Emitter<WorkersState> emit, {
    required bool setLoading,
  }) async {
    if (setLoading) {
      emit(state.copyWith(status: WorkersStatus.loading, errorMessage: null));
    }

    try {
      // 1. Obtener todos los workers del API
      final List<Worker> allWorkers = await _service.getWorkers();
      
      // 2. Obtener el providerId del usuario logueado
      int? providerId;
      final userId = await _onboardingService.getUserId();
      if (userId != null) {
        final token = await _onboardingService.getJwtToken();
        if (token != null) {
          final provider = await _authService.getProviderByUserId(
            userId: userId,
            token: token,
          );
          providerId = provider?.id;
        }
      }

      // 3. Filtrar workers por providerId
      final filteredWorkers = providerId != null
          ? allWorkers.where((worker) => worker.providerId == providerId).toList()
          : <Worker>[];
      
      // 4. Ordenar alfabéticamente
      filteredWorkers.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      emit(state.copyWith(status: WorkersStatus.success, workers: filteredWorkers));
    } catch (error) {
      emit(
        state.copyWith(
          status: WorkersStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
