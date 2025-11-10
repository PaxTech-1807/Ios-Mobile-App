import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/features/service/data/services_service.dart';
import 'package:iosmobileapp/features/service/domain/service.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_event.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  ServicesBloc({required ServicesService service})
    : _service = service,
      super(const ServicesState()) {
    on<LoadServices>(_onLoadServices);
    on<RefreshServices>(_onRefreshServices);
    on<CreateServiceRequested>(_onCreateRequested);
    on<UpdateServiceRequested>(_onUpdateRequested);
    on<DeleteServiceRequested>(_onDeleteRequested);
    on<ServiceFormReset>(_onFormReset);
  }

  final ServicesService _service;

  Future<void> _onLoadServices(
    LoadServices event,
    Emitter<ServicesState> emit,
  ) async {
    await _fetchServices(emit, setLoading: true);
  }

  Future<void> _onRefreshServices(
    RefreshServices event,
    Emitter<ServicesState> emit,
  ) async {
    await _fetchServices(emit, setLoading: false);
  }

  Future<void> _onCreateRequested(
    CreateServiceRequested event,
    Emitter<ServicesState> emit,
  ) async {
    emit(
      state.copyWith(
        formStatus: ServiceFormStatus.submitting,
        formErrorMessage: null,
      ),
    );

    try {
      final Service service = await _service.createService(event.request);
      final List<Service> updated = List<Service>.from(state.services)
        ..add(service);
      updated.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      emit(
        state.copyWith(
          services: updated,
          formStatus: ServiceFormStatus.success,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          formStatus: ServiceFormStatus.failure,
          formErrorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    UpdateServiceRequested event,
    Emitter<ServicesState> emit,
  ) async {
    emit(
      state.copyWith(
        formStatus: ServiceFormStatus.submitting,
        formErrorMessage: null,
      ),
    );

    try {
      final Service service = await _service.updateService(
        serviceId: event.serviceId,
        request: event.request,
      );
      final List<Service> updated =
          state.services
              .map((existing) => existing.id == service.id ? service : existing)
              .toList()
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );

      emit(
        state.copyWith(
          services: updated,
          formStatus: ServiceFormStatus.success,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          formStatus: ServiceFormStatus.failure,
          formErrorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    DeleteServiceRequested event,
    Emitter<ServicesState> emit,
  ) async {
    emit(
      state.copyWith(deletingServiceId: event.serviceId, errorMessage: null),
    );

    try {
      await _service.deleteService(event.serviceId);
      final List<Service> updated = state.services
          .where((service) => service.id != event.serviceId)
          .toList();

      emit(state.copyWith(services: updated, deletingServiceId: null));
    } catch (error) {
      emit(
        state.copyWith(errorMessage: error.toString(), deletingServiceId: null),
      );
    }
  }

  void _onFormReset(ServiceFormReset event, Emitter<ServicesState> emit) {
    emit(
      state.copyWith(
        formStatus: ServiceFormStatus.idle,
        formErrorMessage: null,
      ),
    );
  }

  Future<void> _fetchServices(
    Emitter<ServicesState> emit, {
    required bool setLoading,
  }) async {
    if (setLoading) {
      emit(state.copyWith(status: ServicesStatus.loading, errorMessage: null));
    }

    try {
      final List<Service> services = await _service.getServices();
      services.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      emit(state.copyWith(status: ServicesStatus.success, services: services));
    } catch (error) {
      emit(
        state.copyWith(
          status: ServicesStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
