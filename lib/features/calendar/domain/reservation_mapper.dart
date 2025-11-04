import 'package:iosmobileapp/features/calendar/domain/reservation.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation_groups.dart';

/// Clase helper para transformar reservas en diferentes agrupaciones
class ReservationMapper {
  /// Agrupa reservas por mes
  static List<MonthlyGroup> groupByMonth(List<Reservation> reservations) {
    final Map<String, List<Reservation>> grouped = {};

    for (final reservation in reservations) {
      final date = reservation.timeSlot.startTime;
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

  /// Agrupa reservas por semana
  static List<WeeklyGroup> groupByWeek(List<Reservation> reservations) {
    final Map<DateTime, List<Reservation>> grouped = {};

    for (final reservation in reservations) {
      final date = reservation.timeSlot.startTime;
      final weekStart = _getWeekStart(date);
      // Normalizar a solo fecha (sin hora)
      final weekStartNormalized = DateTime(weekStart.year, weekStart.month, weekStart.day);

      grouped.putIfAbsent(weekStartNormalized, () => []).add(reservation);
    }

    return grouped.entries.map((entry) {
      return WeeklyGroup(
        weekStart: entry.key,
        reservations: entry.value,
      );
    }).toList()
      ..sort((a, b) => a.weekStart.compareTo(b.weekStart));
  }

  /// Agrupa reservas por día
  static List<DailyGroup> groupByDay(List<Reservation> reservations) {
    final Map<String, List<Reservation>> grouped = {};

    for (final reservation in reservations) {
      final date = reservation.timeSlot.startTime;
      // Normalizar a solo fecha (sin hora)
      final dateOnly = DateTime(date.year, date.month, date.day);
      final key = _getDayKey(dateOnly);

      grouped.putIfAbsent(key, () => []).add(reservation);
    }

    return grouped.entries.map((entry) {
      final date = _parseDayKey(entry.key);
      return DailyGroup(
        date: date,
        reservations: entry.value,
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Agrupa reservas por trabajador
  static List<WorkerGroup> groupByWorker(List<Reservation> reservations) {
    final Map<int, List<Reservation>> grouped = {};

    for (final reservation in reservations) {
      final workerId = reservation.workerId.id;
      grouped.putIfAbsent(workerId, () => []).add(reservation);
    }

    return grouped.entries.map((entry) {
      // Tomamos el worker de la primera reserva (todos tienen el mismo worker)
      final worker = entry.value.first.workerId;
      return WorkerGroup(
        worker: worker,
        reservations: entry.value,
      );
    }).toList()
      ..sort((a, b) => a.worker.name.compareTo(b.worker.name));
  }

  // Métodos helper privados

  /// Obtiene el lunes de la semana de una fecha
  static DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1 = lunes, 7 = domingo
    final daysFromMonday = weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Crea una clave única para un día (ej: "2024-03-18")
  static String _getDayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Parsea una clave de día de vuelta a DateTime
  static DateTime _parseDayKey(String key) {
    final parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
