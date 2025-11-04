import 'package:iosmobileapp/features/calendar/domain/reservation.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation_groups.dart';

sealed class ReservationsState {
  const ReservationsState();
}

class ReservationsInitialState extends ReservationsState {
  const ReservationsInitialState();
}

class ReservationsLoadingState extends ReservationsState {
  const ReservationsLoadingState();
}

class ReservationsSuccessState extends ReservationsState {
  final List<Reservation> reservations; // Example reservation data
  final List<MonthlyGroup> monthlyGroups;
  final List<WeeklyGroup> weeklyGroups;
  final List<DailyGroup> dailyGroups;
  final List<WorkerGroup> workerGroups;
  const ReservationsSuccessState({
    required this.reservations,
    required this.monthlyGroups,
    required this.weeklyGroups,
    required this.dailyGroups,
    required this.workerGroups,
  });
//Evitar build inecesarios
   @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReservationsSuccessState &&
        other.reservations == reservations &&
        other.monthlyGroups == monthlyGroups &&
        other.weeklyGroups == weeklyGroups &&
        other.dailyGroups == dailyGroups &&
        other.workerGroups == workerGroups;
  }

  @override
  int get hashCode => Object.hash(
        reservations,
        monthlyGroups,
        weeklyGroups,
        dailyGroups,
        workerGroups,
      );
}

class ReservationsFailureState extends ReservationsState {
  final String errorMessage;

  const ReservationsFailureState(this.errorMessage);
  //Evitar build inecesarios
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReservationsFailureState &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => errorMessage.hashCode;
}