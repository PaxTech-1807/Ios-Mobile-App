// features/calendar/presentation/blocs/timeslot_event.dart
import 'package:iosmobileapp/features/calendar/domain/timeslot_request.dart' show TimeSlotRequest;
abstract class TimeSlotsEvent {
  const TimeSlotsEvent();
}

class LoadTimeSlots extends TimeSlotsEvent {
  const LoadTimeSlots();
}


class CreateTimeSlot extends TimeSlotsEvent {
  final TimeSlotRequest request;
  const CreateTimeSlot({required this.request});
}