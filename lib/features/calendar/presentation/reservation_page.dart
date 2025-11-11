import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/features/calendar/data/calendar_service.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation_groups.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation_mapper.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_bloc.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_event.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_state.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReservationsBloc(service: CalendarService())
        ..add(GetReservationsByRange(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 30)),
        )),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reservaciones'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: BlocBuilder<ReservationsBloc, ReservationsState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildViewTypeButton(
                        context,
                        ViewType.day,
                        'Day',
                        state.viewType == ViewType.day,
                      ),
                      _buildViewTypeButton(
                        context,
                        ViewType.month,
                        'Month',
                        state.viewType == ViewType.month,
                      ),
                      _buildViewTypeButton(
                        context,
                        ViewType.year,
                        'Year',
                        state.viewType == ViewType.year,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        body: BlocBuilder<ReservationsBloc, ReservationsState>(
          builder: (context, state) {
            if (state.status == Status.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == Status.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message ?? "Error desconocido"}'),
                  ],
                ),
              );
            }

            if (state.reservations.isEmpty) {
              return const Center(
                child: Text('No hay reservaciones en este rango'),
              );
            }

            // Agrupar según el tipo de vista
            return _buildGroupedList(state);
          },
        ),
      ),
    );
  }

  Widget _buildViewTypeButton(
    BuildContext context,
    ViewType viewType,
    String label,
    bool isSelected,
  ) {
    return ElevatedButton(
      onPressed: () {
        context.read<ReservationsBloc>().add(ChangeViewType(viewType: viewType));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey,
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }

  Widget _buildGroupedList(ReservationsState state) {
    switch (state.viewType) {
      case ViewType.day:
        return _buildDailyGroups(state);
      case ViewType.month:
        return _buildMonthlyGroups(state);
      case ViewType.year:
        return _buildYearlyGroups(state);
    }
  }

  Widget _buildDailyGroups(ReservationsState state) {
    final dailyGroups = ReservationMapper.groupByDay(state.reservations);

    if (dailyGroups.isEmpty) {
      return const Center(child: Text('No hay reservaciones'));
    }

    return ListView.builder(
      itemCount: dailyGroups.length,
      itemBuilder: (context, index) {
        final group = dailyGroups[index];
        return ExpansionTile(
          title: Text(group.displayName),
          subtitle: Text('${group.reservations.length} reservas'),
          children: group.reservations.map((reservation) {
            return ListTile(
              title: Text('Reserva #${reservation.id}'),
              subtitle: Text(
                '${reservation.timeSlot.startTime.toString().substring(11, 16)} - ${reservation.serviceId.name}',
              ),
              trailing: Text(reservation.workerId.name),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMonthlyGroups(ReservationsState state) {
    final monthlyGroups = ReservationMapper.groupByMonth(state.reservations);

    if (monthlyGroups.isEmpty) {
      return const Center(child: Text('No hay reservaciones'));
    }

    return ListView.builder(
      itemCount: monthlyGroups.length,
      itemBuilder: (context, index) {
        final group = monthlyGroups[index];
        return ExpansionTile(
          title: Text(group.displayName),
          subtitle: Text('${group.reservations.length} reservas'),
          children: group.reservations.map((reservation) {
            return ListTile(
              title: Text('Reserva #${reservation.id}'),
              subtitle: Text(
                '${reservation.timeSlot.startTime.toString().substring(0, 16)} - ${reservation.serviceId.name}',
              ),
              trailing: Text(reservation.workerId.name),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildYearlyGroups(ReservationsState state) {
    final yearlyGroups = ReservationMapper.groupByYear(state.reservations);

    if (yearlyGroups.isEmpty) {
      return const Center(child: Text('No hay reservaciones'));
    }

    return ListView.builder(
      itemCount: yearlyGroups.length,
      itemBuilder: (context, index) {
        final group = yearlyGroups[index];
        return ExpansionTile(
          title: Text(group.displayName),
          subtitle: Text('${group.reservations.length} reservas'),
          children: group.reservations.map((reservation) {
            return ListTile(
              title: Text('Reserva #${reservation.id}'),
              subtitle: Text(
                '${reservation.timeSlot.startTime.toString().substring(0, 16)} - ${reservation.serviceId.name}',
              ),
              trailing: Text(reservation.workerId.name),
            );
          }).toList(),
        );
      },
    );
  }
}