import 'package:iosmobileapp/features/service/domain/service.dart';

abstract class ServicesEvent {
  const ServicesEvent();
}

class LoadServices extends ServicesEvent {
  const LoadServices();
}

class RefreshServices extends ServicesEvent {
  const RefreshServices();
}

class CreateServiceRequested extends ServicesEvent {
  final ServiceRequest request;

  const CreateServiceRequested({required this.request});
}

class UpdateServiceRequested extends ServicesEvent {
  final int serviceId;
  final ServiceRequest request;

  const UpdateServiceRequested({
    required this.serviceId,
    required this.request,
  });
}

class DeleteServiceRequested extends ServicesEvent {
  final int serviceId;

  const DeleteServiceRequested({required this.serviceId});
}

class ServiceFormReset extends ServicesEvent {
  const ServiceFormReset();
}
