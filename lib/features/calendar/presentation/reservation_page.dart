import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/features/calendar/data/calendar_service.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_bloc.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_event.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_state.dart';

class ReservationPage extends StatelessWidget {
  const ReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReservationView();
  }
}

class ReservationView extends StatelessWidget {
  const ReservationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas - Prueba'),
      ),
      body: BlocBuilder<ReservationsBloc, ReservationsState>(
        builder: (context, state) {
          // Estado inicial
          if (state is ReservationsInitialState) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<ReservationsBloc>().add(const GetReservationsEvent());
                },
                child: const Text('Cargar Reservas'),
              ),
            );
          }

          // Estado de carga
          if (state is ReservationsLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Estado de error
          if (state is ReservationsFailureState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.errorMessage}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ReservationsBloc>().add(const GetReservationsEvent());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Estado de éxito
          if (state is ReservationsSuccessState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen general
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Total Reservas: ${state.reservations.length}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text('Meses: ${state.monthlyGroups.length}'),
                            Text('Semanas: ${state.weeklyGroups.length}'),
                            Text('Días: ${state.dailyGroups.length}'),
                            Text('Trabajadores: ${state.workerGroups.length}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Vista Mensual
                    Text(
                      'Vista Mensual',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    ...state.monthlyGroups.map((month) => Card(
                          child: ListTile(
                            title: Text(month.displayName),
                            subtitle: Text('${month.reservations.length} reservas'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReservationDetailsPage(
                                    title: month.displayName,
                                    reservations: month.reservations,
                                  ),
                                ),
                              );
                            },
                          ),
                        )),
                    const SizedBox(height: 20),

                    // Vista Semanal
                    Text(
                      'Vista Semanal',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    ...state.weeklyGroups.map((week) => Card(
                          child: ListTile(
                            title: Text(week.displayName),
                            subtitle: Text('${week.reservations.length} reservas - ${week.dateRange}'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReservationDetailsPage(
                                    title: week.displayName,
                                    reservations: week.reservations,
                                  ),
                                ),
                              );
                            },
                          ),
                        )),
                    const SizedBox(height: 20),

                    // Vista Diaria
                    Text(
                      'Vista Diaria',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    ...state.dailyGroups.map((day) => Card(
                          child: ListTile(
                            title: Text(day.displayName),
                            subtitle: Text('${day.reservations.length} reservas - ${day.shortDate}'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReservationDetailsPage(
                                    title: day.displayName,
                                    reservations: day.reservations,
                                  ),
                                ),
                              );
                            },
                          ),
                        )),
                    const SizedBox(height: 20),

                    // Vista por Trabajador
                    Text(
                      'Vista por Trabajador',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    ...state.workerGroups.map((workerGroup) => Card(
                          child: ListTile(
                            title: Text(workerGroup.worker.name),
                            subtitle: Text(
                              '${workerGroup.worker.specialization} - ${workerGroup.reservations.length} reservas',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReservationDetailsPage(
                                    title: '${workerGroup.worker.name} - ${workerGroup.worker.specialization}',
                                    reservations: workerGroup.reservations,
                                  ),
                                ),
                              );
                            },
                          ),
                        )),
                  ],
                ),
              ),
            );
          }

          // Fallback
          return const Center(child: Text('Estado desconocido'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<ReservationsBloc>().add(const GetReservationsEvent());
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// Nueva pantalla para mostrar detalles de las reservas
class ReservationDetailsPage extends StatelessWidget {
  final String title;
  final List<Reservation> reservations;

  const ReservationDetailsPage({
    super.key,
    required this.title,
    required this.reservations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: reservations.isEmpty
          ? const Center(child: Text('No hay reservas'))
          : ListView.builder(
              itemCount: reservations.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ID de Reserva
                        Text(
                          'Reserva #${reservation.id}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Información del Cliente
                        _buildInfoRow('Cliente ID:', reservation.clientId.toString()),
                        const SizedBox(height: 8),

                        // Información del Proveedor
                        Text(
                          'Proveedor',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        _buildInfoRow('  Nombre:', reservation.provider.name),
                        _buildInfoRow('  Empresa:', reservation.provider.companyName),
                        const SizedBox(height: 8),

                        // Información del Trabajador
                        Text(
                          'Trabajador',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        _buildInfoRow('  Nombre:', reservation.workerId.name),
                        _buildInfoRow('  Especialización:', reservation.workerId.specialization),
                        const SizedBox(height: 8),

                        // Información de Horario
                        Text(
                          'Horario',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        _buildInfoRow(
                          '  Inicio:',
                          '${_formatDateTime(reservation.timeSlot.startTime)}',
                        ),
                        _buildInfoRow(
                          '  Fin:',
                          '${_formatDateTime(reservation.timeSlot.endTime)}',
                        ),
                        _buildInfoRow('  Tipo:', reservation.timeSlot.type),
                        _buildInfoRow(
                          '  Estado:',
                          reservation.timeSlot.status ? 'Activo' : 'Inactivo',
                        ),
                        const SizedBox(height: 8),

                        // Información de Pago
                        Text(
                          'Pago',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        _buildInfoRow(
                          '  Monto:',
                          '${reservation.paymentId.amount} ${reservation.paymentId.currency}',
                        ),
                        _buildInfoRow(
                          '  Estado:',
                          reservation.paymentId.status ? 'Pagado' : 'Pendiente',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
//ESTE ui es solo de prueba, Se tiene que cambiar por completo por lo que hay dentro de los wireflows.
