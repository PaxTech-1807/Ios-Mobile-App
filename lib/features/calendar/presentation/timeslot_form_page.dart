// features/calendar/presentation/timeslot_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:iosmobileapp/features/calendar/domain/timeslot_request.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/timeslot_bloc.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/timeslot_event.dart';

class TimeSlotFormPage extends StatefulWidget {
  const TimeSlotFormPage({super.key});

  @override
  State<TimeSlotFormPage> createState() => _TimeSlotFormPageState();
}

class _TimeSlotFormPageState extends State<TimeSlotFormPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _startTime;
  DateTime? _endTime;
  bool _status = true; // Por defecto disponible

  // El tipo por defecto que parece funcionar.
  final _typeController = TextEditingController(text: 'string');

  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  // Función genérica para elegir fecha y hora
  Future<DateTime?> _pickDateTime(DateTime? initialDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return null;

    // ignore: use_build_context_synchronously
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final request = TimeSlotRequest(
        startTime: _startTime!,
        endTime: _endTime!,
        status: _status,
        type: _typeController.text, // Envía lo que el usuario escriba
      );

      // Enviamos el evento al BLoC
      context.read<TimeSlotsBloc>().add(CreateTimeSlot(request: request));

      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Horario'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Selector de Hora de Inicio ---
              TextFormField(
                controller: _startTimeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Hora de Inicio',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  _startTime = await _pickDateTime(_startTime);
                  if (_startTime != null) {
                    _startTimeController.text =
                        DateFormat('EEE, d MMM - hh:mm a', 'es_ES')
                            .format(_startTime!);
                    // Autocompleta la hora final si está vacía
                    if (_endTime == null) {
                      _endTime = _startTime!.add(const Duration(hours: 1));
                      _endTimeController.text =
                          DateFormat('EEE, d MMM - hh:mm a', 'es_ES')
                              .format(_endTime!);
                    }
                  }
                },
                validator: (v) => _startTime == null ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              // --- Selector de Hora de Fin ---
              TextFormField(
                controller: _endTimeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Hora de Fin',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  _endTime = await _pickDateTime(_endTime);
                  if (_endTime != null) {
                    _endTimeController.text =
                        DateFormat('EEE, d MMM - hh:mm a', 'es_ES')
                            .format(_endTime!);
                  }
                },
                validator: (v) => _endTime == null ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              // --- ¡CAMPO DE TIPO (AHORA VISIBLE)! ---
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Tipo (ej. string, a, RESERVATION)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              // --- Switch de Estado (Disponible) ---
              SwitchListTile(
                title: const Text('Disponible (Status)'),
                value: _status,
                onChanged: (newValue) {
                  setState(() {
                    _status = newValue;
                  });
                },
              ),
              const SizedBox(height: 32),

              // --- Botón de Guardar ---
              FilledButton(
                onPressed: _submitForm,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Guardar Horario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}