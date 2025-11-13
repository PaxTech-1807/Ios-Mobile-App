// features/calendar/domain/timeslot_request.dart

class TimeSlotRequest {
  final DateTime startTime;
  final DateTime endTime;
  final bool status;
  final String type;

  TimeSlotRequest({
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'type': type,
    };
  }
}