import 'package:iosmobileapp/features/calendar/domain/reservation.dart';

class MonthlyGroup {
  final int year;
  final int month;
  final List<Reservation> reservations;
  MonthlyGroup({
    required this.year,
    required this.month,
    required this.reservations,
  });

  /// Clave única para el mes (ej: "2024-03")
  String get key => '$year-${month.toString().padLeft(2, '0')}';

  /// Nombre del mes (ej: "Marzo 2024")
  String get displayName {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${months[month - 1]} $year';
  }
}

/// Agrupación semanal: contiene el inicio de semana y las reservas
class WeeklyGroup {
  final DateTime weekStart; // Primer día de la semana (lunes)
  final List<Reservation> reservations;
  
  WeeklyGroup({
    required this.weekStart,
    required this.reservations,
  });

  /// Último día de la semana (domingo)
  DateTime get weekEnd => weekStart.add(const Duration(days: 6));
  
  /// Clave única para la semana (ej: "2024-W12")
  String get key {
    final year = weekStart.year;
    final weekNumber = _getWeekNumber(weekStart);
    return '$year-W${weekNumber.toString().padLeft(2, '0')}';
  }
  
  /// Nombre de la semana (ej: "Semana 12 - 2024")
  String get displayName {
    final weekNumber = _getWeekNumber(weekStart);
    return 'Semana $weekNumber - ${weekStart.year}';
  }
  
  /// Rango de fechas (ej: "18-24 Marzo 2024")
  String get dateRange {
    final startDay = weekStart.day;
    final endDay = weekEnd.day;
    final monthName = _getMonthName(weekStart.month);
    final year = weekStart.year;
    return '$startDay-$endDay $monthName $year';
  }
  
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }
  
  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }
}

/// Agrupación diaria: contiene la fecha y las reservas del día
class DailyGroup {
  final DateTime date; // Solo fecha (sin hora)
  final List<Reservation> reservations;
  
  DailyGroup({
    required this.date,
    required this.reservations,
  });

  /// Clave única para el día (ej: "2024-03-18")
  String get key {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// Nombre del día (ej: "Lunes, 18 Marzo 2024")
  String get displayName {
    const weekdays = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, ${date.day} $month ${date.year}';
  }
  
  /// Formato corto (ej: "18/03/2024")
  String get shortDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Agrupación por trabajador: contiene el trabajador y sus reservas
class WorkerGroup {
  final Worker worker;
  final List<Reservation> reservations;
  
  WorkerGroup({
    required this.worker,
    required this.reservations,
  });

  /// Clave única para el trabajador (su ID)
  String get key => worker.id.toString();
  
  /// Nombre del trabajador con especialización
  String get displayName => '${worker.name} - ${worker.specialization}';
}
