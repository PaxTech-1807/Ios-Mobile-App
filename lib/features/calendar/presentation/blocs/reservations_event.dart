import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_state.dart';

abstract class ReservationsEvent {}

class GetReservationsByRange extends ReservationsEvent {
  final DateTime startDate;
  final DateTime endDate;

  GetReservationsByRange({
    required this.startDate,
    required this.endDate,
  });
}

class ChangeViewType extends ReservationsEvent {
  final ViewType viewType;

  ChangeViewType({required this.viewType});
}