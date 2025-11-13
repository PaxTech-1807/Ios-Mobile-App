import 'package:iosmobileapp/features/service/domain/service.dart';

enum ServicesStatus { initial, loading, success, failure }

enum ServiceFormStatus { idle, submitting, success, failure }

class ServicesState {
  static const Object _unset = Object();

  final ServicesStatus status;
  final List<Service> services;
  final String? errorMessage;
  final ServiceFormStatus formStatus;
  final String? formErrorMessage;
  final int? deletingServiceId;

  const ServicesState({
    this.status = ServicesStatus.initial,
    this.services = const [],
    this.errorMessage,
    this.formStatus = ServiceFormStatus.idle,
    this.formErrorMessage,
    this.deletingServiceId,
  });

  ServicesState copyWith({
    ServicesStatus? status,
    List<Service>? services,
    Object? errorMessage = _unset,
    ServiceFormStatus? formStatus,
    Object? formErrorMessage = _unset,
    Object? deletingServiceId = _unset,
  }) {
    return ServicesState(
      status: status ?? this.status,
      services: services ?? this.services,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      formStatus: formStatus ?? this.formStatus,
      formErrorMessage: formErrorMessage == _unset
          ? this.formErrorMessage
          : formErrorMessage as String?,
      deletingServiceId: deletingServiceId == _unset
          ? this.deletingServiceId
          : deletingServiceId as int?,
    );
  }
}
