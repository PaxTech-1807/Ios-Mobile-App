import 'package:iosmobileapp/features/team/domain/worker.dart';

enum WorkersStatus { initial, loading, success, failure }

enum WorkerFormStatus { idle, submitting, success, failure }

class WorkersState {
  static const Object _unset = Object();

  final WorkersStatus status;
  final List<Worker> workers;
  final String? errorMessage;
  final WorkerFormStatus formStatus;
  final String? formErrorMessage;
  final int? deletingWorkerId;

  const WorkersState({
    this.status = WorkersStatus.initial,
    this.workers = const [],
    this.errorMessage,
    this.formStatus = WorkerFormStatus.idle,
    this.formErrorMessage,
    this.deletingWorkerId,
  });

  WorkersState copyWith({
    WorkersStatus? status,
    List<Worker>? workers,
    Object? errorMessage = _unset,
    WorkerFormStatus? formStatus,
    Object? formErrorMessage = _unset,
    Object? deletingWorkerId = _unset,
  }) {
    return WorkersState(
      status: status ?? this.status,
      workers: workers ?? this.workers,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      formStatus: formStatus ?? this.formStatus,
      formErrorMessage: formErrorMessage == _unset
          ? this.formErrorMessage
          : formErrorMessage as String?,
      deletingWorkerId: deletingWorkerId == _unset
          ? this.deletingWorkerId
          : deletingWorkerId as int?,
    );
  }
}
