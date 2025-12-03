import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/features/calendar/data/calendar_service.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_event.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_state.dart';

class ReservationsBloc extends Bloc<ReservationsEvent, ReservationsState>{
  final CalendarService service;

  ReservationsBloc({required this.service}): super(ReservationsState()) {
    on<GetReservationsByRange>(_getReservationsByRange);
    on<ChangeViewType>((event, emit) {
      emit(state.copyWith(viewType: event.viewType));
    });
  }

  FutureOr<void> _getReservationsByRange(
    GetReservationsByRange event,
    Emitter<ReservationsState> emit
  ) async {
    if(state.startDate == event.startDate &&
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
}