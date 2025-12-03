import 'package:iosmobileapp/features/team/domain/worker.dart';

abstract class WorkersEvent {
  const WorkersEvent();
}

class LoadWorkers extends WorkersEvent {
  const LoadWorkers();
}

class RefreshWorkers extends WorkersEvent {
  const RefreshWorkers();
}

class CreateWorkerRequested extends WorkersEvent {
  final WorkerRequest request;

  const CreateWorkerRequested({required this.request});
}

class UpdateWorkerRequested extends WorkersEvent {
  final int workerId;
  final WorkerRequest request;

  const UpdateWorkerRequested({required this.workerId, required this.request});
}

class DeleteWorkerRequested extends WorkersEvent {
  final int workerId;

  const DeleteWorkerRequested({required this.workerId});
}

class WorkerFormReset extends WorkersEvent {
  const WorkerFormReset();
}
