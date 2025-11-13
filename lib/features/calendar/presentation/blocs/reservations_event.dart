import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_state.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation_request.dart';
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

class CreateReservation extends ReservationsEvent {
  final ReservationRequest request;

  CreateReservation({required this.request});
}