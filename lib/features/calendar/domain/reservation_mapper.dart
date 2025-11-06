import 'package:iosmobileapp/features/calendar/domain/reservation.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation_groups.dart';

class ReservationMapper {
  static List<DailyGroup> groupByDay(List<Reservation> reservations) {
    final Map<String, List<Reservation>> grouped = {};

    for (final reservation in reservations) {
      final date = reservation.timeSlot.startTime;
      final dateOnly = DateTime(date.year, date.month, date.day);
            final key = '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(reservation); //Crear lista vacia y agregar reserva
    }
    return grouped.entries.map((entry) {
      final parts = entry.key.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return DailyGroup(date: date, reservations: entry.value);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

   /// Agrupa reservas por mes
  static List<MonthlyGroup> groupByMonth(List<Reservation> reservations) {
    final Map<String, List<Reservation>> grouped = {};

    for (final reservation in reservations) {
      final date = reservation.timeSlot.startTime;
      // Clave: "2024-03" (año-mes)
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(reservation);
    }

    return grouped.entries.map((entry) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      return MonthlyGroup(
        year: year,
        month: month,
        reservations: entry.value,
      );
    }).toList()
      ..sort((a, b) {
        if (a.year != b.year) return a.year.compareTo(b.year);
        return a.month.compareTo(b.month);
      });
  }

    /// Agrupa reservas por año
  static List<YearlyGroup> groupByYear(List<Reservation> reservations) {
    final Map<int, List<Reservation>> grouped = {};

    for (final reservation in reservations) {
      final year = reservation.timeSlot.startTime.year;
      grouped.putIfAbsent(year, () => []).add(reservation);
    }

    return grouped.entries.map((entry) {
      return YearlyGroup(
        year: entry.key,
        reservations: entry.value,
      );
    }).toList()
      ..sort((a, b) => a.year.compareTo(b.year));
  }
}

