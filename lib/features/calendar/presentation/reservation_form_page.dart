// features/calendar/presentation/reservation_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
// ¡AQUÍ ESTÁ LA CORRECCIÓN!
import 'package:iosmobileapp/features/calendar/domain/reservation.dart' show TimeSlot; // Importa SOLO TimeSlot
import 'package:iosmobileapp/features/calendar/domain/reservation_request.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_bloc.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_event.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/timeslot_bloc.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/timeslot_state.dart';
import 'package:iosmobileapp/features/service/domain/service.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_bloc.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_state.dart';
import 'package:iosmobileapp/features/team/domain/worker.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_bloc.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_state.dart';

class ReservationFormPage extends StatefulWidget {
  const ReservationFormPage({super.key});

  @override
  State<ReservationFormPage> createState() => _ReservationFormPageState();
}

class _ReservationFormPageState extends State<ReservationFormPage> {
  final _formKey = GlobalKey<FormState>();

  Service? _selectedService;
  Worker? _selectedWorker; // Ahora ya no tendrá conflicto
  TimeSlot? _selectedTimeSlot;

  // Helper para formatear la fecha
  String _formatTimeSlot(TimeSlot slot) {
    // Formatea la fecha a algo legible: "Vie, 5 Nov - 02:05 AM"
    return DateFormat('EEE, d MMM - hh:mm a', 'es_ES').format(slot.startTime);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final request = ReservationRequest(
        // IDs fijos para cliente y proveedor
        clientId: 3,
        providerId: 1,
        // IDs de los dropdowns
        serviceId: _selectedService!.id,
        workerId: _selectedWorker!.id,
        timeSlotId: _selectedTimeSlot!.id,
      );

      // Enviar el evento al BLoC
      context.read<ReservationsBloc>().add(CreateReservation(request: request));

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear nueva cita'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Selector de Servicio ---
              BlocBuilder<ServicesBloc, ServicesState>(
                builder: (context, state) {
                  if (state.status != ServicesStatus.success) {
                    // Mejora: Muestra un indicador de carga
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DropdownButtonFormField<Service>(
                    value: _selectedService,
                    hint: const Text('Seleccionar servicio'),
                    decoration:
                    const InputDecoration(border: OutlineInputBorder()),
                    items: state.services.map((service) {
                      return DropdownMenuItem(
                        value: service,
                        child: Text(service.name),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedService = value),
                    validator: (v) => v == null ? 'Campo requerido' : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // --- Selector de Trabajador ---
              BlocBuilder<WorkersBloc, WorkersState>(
                builder: (context, state) {
                  if (state.status != WorkersStatus.success) {
                    // Mejora: Muestra un indicador de carga o el error
                    if (state.status == WorkersStatus.loading || state.status == WorkersStatus.initial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == WorkersStatus.failure) {
                      return Text(
                        'Error al cargar equipo: ${state.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      );
                    }
                    return const Text('Cargando equipo...');
                  }
                  return DropdownButtonFormField<Worker>(
                    value: _selectedWorker,
                    hint: const Text('Seleccionar profesional'),
                    decoration:
                    const InputDecoration(border: OutlineInputBorder()),
                    items: state.workers.map((worker) {
                      return DropdownMenuItem(
                        value: worker,
                        child: Text(worker.name),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedWorker = value),
                    validator: (v) => v == null ? 'Campo requerido' : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // --- ¡NUEVO SELECTOR DE HORARIOS (TimeSlot)! ---
              BlocBuilder<TimeSlotsBloc, TimeSlotsState>(
                builder: (context, state) {
                  // 1. Manejo de estados de carga y error
                  if (state.status == TimeSlotsStatus.loading ||
                      state.status == TimeSlotsStatus.initial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == TimeSlotsStatus.failure) {
                    return Text(
                      'Error al cargar horarios: ${state.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  if (state.timeSlots.isEmpty) {
                    return const Text('No hay horarios disponibles.');
                  }

                  // 2. El Dropdown si todo está bien
                  return DropdownButtonFormField<TimeSlot>(
                    value: _selectedTimeSlot,
                    hint: const Text('Seleccionar horario disponible'),
                    decoration:
                    const InputDecoration(border: OutlineInputBorder()),
                    items: state.timeSlots.map((slot) {
                      return DropdownMenuItem(
                        value: slot,
                        // Muestra la fecha/hora formateada
                        child: Text(_formatTimeSlot(slot)),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedTimeSlot = value),
                    validator: (v) => v == null ? 'Campo requerido' : null,
                  );
                },
              ),
              const SizedBox(height: 32),

              // --- Botón de Guardar ---
              FilledButton(
                onPressed: _submitForm,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Agendar Cita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}