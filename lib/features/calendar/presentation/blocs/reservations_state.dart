import 'package:iosmobileapp/features/calendar/domain/reservation.dart';

enum Status { initial, loading, success, failure }
enum ViewType { day, month, year }

class ReservationsState {
  final List<Reservation> reservations;
  final Status status;
  final String? message;
  final DateTime? startDate;
  final DateTime? endDate;
  final ViewType viewType;

  const ReservationsState({
    this.reservations = const [],
    this.status = Status.initial,
    this.message,
    this.startDate,
    this.endDate,
    this.viewType = ViewType.month,
  });

  ReservationsState copyWith({
    List<Reservation>? reservations,
    Status? status,
    String? message,
    DateTime? startDate,
    DateTime? endDate,
    ViewType? viewType,
  }) {
    return ReservationsState(
      reservations: reservations ?? this.reservations,
      status: status ?? this.status,
      message: message ?? this.message,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      viewType: viewType ?? this.viewType,
    );
  }
}