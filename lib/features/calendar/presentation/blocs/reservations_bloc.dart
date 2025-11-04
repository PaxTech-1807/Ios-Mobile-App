import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/features/calendar/data/calendar_service.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation_mapper.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_event.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_state.dart';

class ReservationsBloc extends Bloc<ReservationsEvent, ReservationsState>{
  final CalendarService service;

  ReservationsBloc(this.service) : super(const ReservationsInitialState()) {
    on<GetReservationsEvent>((event, emit) async {
      emit(const ReservationsLoadingState());
      try {
        List<Reservation> reservations = await service.getReservations();
        final monthlyGroups = ReservationMapper.groupByMonth(reservations);
        final weeklyGroups = ReservationMapper.groupByWeek(reservations);
        final dailyGroups = ReservationMapper.groupByDay(reservations);
        final workerGroups = ReservationMapper.groupByWorker(reservations);
        emit(ReservationsSuccessState(reservations:reservations,
          monthlyGroups: monthlyGroups,
          weeklyGroups: weeklyGroups,
          dailyGroups: dailyGroups,
          workerGroups: workerGroups,
        ));
      } catch (e) {
        emit(ReservationsFailureState(e.toString()));
      }
    });

    
  }
}