// features/calendar/presentation/blocs/timeslot_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/features/calendar/data/timeslot_service.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation.dart'; // Importa TimeSlot
import 'package:iosmobileapp/features/calendar/domain/timeslot_request.dart'; // Importa TimeSlotRequest
import 'package:iosmobileapp/features/calendar/presentation/blocs/timeslot_event.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/timeslot_state.dart';

class TimeSlotsBloc extends Bloc<TimeSlotsEvent, TimeSlotsState> {
  final TimeSlotService _service;

  TimeSlotsBloc({required TimeSlotService service})
      : _service = service,
        super(const TimeSlotsState()) {
    on<LoadTimeSlots>(_onLoadTimeSlots);
    on<CreateTimeSlot>(_onCreateTimeSlot); // <-- ¡AÑADE ESTA LÍNEA!
  }

  Future<void> _onLoadTimeSlots(
      LoadTimeSlots event,
      Emitter<TimeSlotsState> emit,
      ) async {
    // ... (tu código existente de _onLoadTimeSlots)
    emit(state.copyWith(status: TimeSlotsStatus.loading));
    try {
      final slots = await _service.getTimeSlots();
      emit(state.copyWith(status: TimeSlotsStatus.success, timeSlots: slots));
    } catch (e) {
      emit(state.copyWith(
          status: TimeSlotsStatus.failure, errorMessage: e.toString()));
    }
  }

  // --- ¡AÑADE ESTE NUEVO MÉTODO! ---
  Future<void> _onCreateTimeSlot(
      CreateTimeSlot event,
      Emitter<TimeSlotsState> emit,
      ) async {
    try {
      final newSlot = await _service.createTimeSlot(event.request);

      // Agrega el nuevo slot a la lista existente
      final updatedList = List<TimeSlot>.from(state.timeSlots)..add(newSlot);

      // Emite el estado de éxito con la lista actualizada
      emit(state.copyWith(
        status: TimeSlotsStatus.success,
        timeSlots: updatedList,
      ));
    } catch (e) {
      // Opcional: emitir un estado de error
      print('Error al crear TimeSlot: $e');
      emit(state.copyWith(
        status: TimeSlotsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}