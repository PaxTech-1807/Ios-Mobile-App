import 'package:iosmobileapp/features/calendar/domain/reservation.dart';

class DailyGroup {
  final DateTime date;
  final List<Reservation> reservations;

  DailyGroup({required this.date, required this.reservations});

  String get displayName {
    const weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final weekDay = weekDays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekDay, ${date.day} $month ${date.year}';
  }
}

class MonthlyGroup {
  final int year;
  final int month;
  final List<Reservation> reservations;
  MonthlyGroup({required this.year, required this.month, required this.reservations});

  String get displayName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final monthName = months[month - 1];
    return '$monthName $year';
  }
}

class YearlyGroup {
  final int year;
  final List<Reservation> reservations;
  YearlyGroup({required this.year, required this.reservations});
  String get displayName {
    return 'Year $year';
  }
}