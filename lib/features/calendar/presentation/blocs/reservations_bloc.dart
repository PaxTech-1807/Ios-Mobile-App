import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/features/calendar/data/calendar_service.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation.dart';
// Importar
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_event.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_state.dart';

class ReservationsBloc extends Bloc<ReservationsEvent, ReservationsState> {
  final CalendarService service;

  ReservationsBloc({required this.service}) : super(ReservationsState()) {
    on<GetReservationsByRange>(_getReservationsByRange);
    on<ChangeViewType>((event, emit) {
      emit(state.copyWith(viewType: event.viewType));
    });

    // --- ¡NUEVO HANDLER! ---
    on<CreateReservation>(_onCreateReservation);
  }

  FutureOr<void> _getReservationsByRange(
      GetReservationsByRange event,
      Emitter<ReservationsState> emit,
      ) async {
    // (Este es tu código original, asegúrate de que esté aquí)
    if (state.startDate == event.startDate &&
        state.endDate == event.endDate &&
        state.reservations.isNotEmpty) {
      return;
    }
    emit(state.copyWith(
      status: Status.loading,
      startDate: event.startDate,
      endDate: event.endDate,
    ));

    try {
      List<Reservation> reservations = await service.getReservations();
      reservations = reservations.where((reservation) {
        final startTime = reservation.timeSlot.startTime;
        return !startTime.isBefore(event.startDate) &&
            !startTime.isAfter(event.endDate);
      }).toList();
      emit(state.copyWith(
        status: Status.success,
        reservations: reservations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        message: e.toString(),
      ));
    }
  }


  FutureOr<void> _onCreateReservation(
      CreateReservation event,
      Emitter<ReservationsState> emit,
      ) async {
    try {
      // 1. Llama al servicio para crear la reserva en el backend
      final newReservation = await service.createReservation(event.request);

      // 2. Agrega la nueva reserva al estado local
      final updatedList = List<Reservation>.from(state.reservations)
        ..add(newReservation);

      // 3. Emite el nuevo estado (esto refrescará el calendario)
      emit(state.copyWith(reservations: updatedList));
    } catch (e) {
      print("Error al crear reserva en BLoC: $e");
    }
  }
}