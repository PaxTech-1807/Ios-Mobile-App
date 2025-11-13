// features/calendar/presentation/blocs/timeslot_state.dart

import 'package:iosmobileapp/features/calendar/domain/reservation.dart'; // Importa TimeSlot

enum TimeSlotsStatus { initial, loading, success, failure }

class TimeSlotsState {
  final TimeSlotsStatus status;
  final List<TimeSlot> timeSlots;
  final String? errorMessage;

  const TimeSlotsState({
    this.status = TimeSlotsStatus.initial,
    this.timeSlots = const [],
    this.errorMessage,
  });

  TimeSlotsState copyWith({
    TimeSlotsStatus? status,
    List<TimeSlot>? timeSlots,
    String? errorMessage,
  }) {
    return TimeSlotsState(
      status: status ?? this.status,
      timeSlots: timeSlots ?? this.timeSlots,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}