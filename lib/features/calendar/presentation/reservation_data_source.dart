import 'package:flutter/material.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation.dart'; // Importa tu modelo
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Esta clase "traduce" tu [Reservation] al [Appointment] que el calendario necesita.
class ReservationDataSource extends CalendarDataSource {

  /// El constructor recibe la lista de reservaciones del BLoC
  ReservationDataSource(List<Reservation> source) {
    appointments = source.map((reservation) {

      // Mapea los campos
      return Appointment(
        startTime: reservation.timeSlot.startTime,
        endTime: reservation.timeSlot.endTime,
        subject: reservation.serviceId.name, // El título del bloque
        notes: reservation.workerId.name,   // Notas (usamos para el trabajador)
        color: _getReservationColor(reservation.workerId.id), // Color por trabajador
      );
    }).toList();
  }

  /// Define los colores para los bloques (como en la Pantalla 1: "Horarios generales")
  Color _getReservationColor(int workerId) {
    // Esta lógica simple asigna un color basado en el ID del trabajador.
    // Así "Javier Herrera" siempre tendrá un color, "Lili Diaz" otro, etc.
    final colors = [
      Colors.pink.withOpacity(0.7),
      Colors.lightBlue.withOpacity(0.7),
      Colors.green.withOpacity(0.7),
      Colors.orange.withOpacity(0.7),
    ];
    // Asigna un color de la lista de forma rotativa
    final colorIndex = workerId % colors.length;
    return colors[colorIndex];
  }
}