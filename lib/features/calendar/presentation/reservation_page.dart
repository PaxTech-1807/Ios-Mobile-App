// features/calendar/presentation/reservation_page.dart
import 'package:iosmobileapp/features/calendar/domain/reservation.dart' show Reservation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/features/calendar/data/calendar_service.dart';
import 'package:iosmobileapp/features/calendar/data/timeslot_service.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_bloc.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_event.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_state.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/timeslot_bloc.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/timeslot_event.dart';
import 'package:iosmobileapp/features/service/data/services_service.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_bloc.dart';
import 'package:iosmobileapp/features/service/presentation/blocs/services_event.dart';
import 'package:iosmobileapp/features/team/data/team_service.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_bloc.dart';
import 'package:iosmobileapp/features/team/presentation/blocs/workers_event.dart';
// ¡NUEVO IMPORT! Necesitamos el estado de Workers para el dropdown
import 'package:iosmobileapp/features/team/presentation/blocs/workers_state.dart';
// ¡NUEVO IMPORT! Necesitamos el modelo Worker para el dropdown
import 'package:iosmobileapp/features/team/domain/worker.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// Importa los adaptadores y formularios
import 'reservation_data_source.dart';
import 'reservation_form_page.dart';
import 'timeslot_form_page.dart';

enum CalendarViewType { week, day, month }

class ReservationPage extends StatelessWidget {
  const ReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Pega tu token NUEVO y VÁLIDO aquí
    final String myAuthToken = 'eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJjYXJvY2Fyb0BnbWFpbC5jb20iLCJpYXQiOjE3NjI5MDk5NjIsImV4cCI6MTc2MzUxNDc2Mn0.jr_CP1m6Z9Uj0-13okXMGLmTnbFIIJL06aSCRbHbQjN2tMSDTbz-Mr0b0XOZ0iJb';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReservationsBloc(
            service: CalendarService(authToken: myAuthToken),
          )..add(GetReservationsByRange(
            startDate: DateTime.now().subtract(const Duration(days: 90)),
            endDate: DateTime.now().add(const Duration(days: 90)),
          )),
        ),
        BlocProvider(
          create: (context) => ServicesBloc(
            service: ServicesService(authToken: myAuthToken),
          )..add(const LoadServices()),
        ),
        BlocProvider(
          create: (context) => WorkersBloc(
            service: TeamService(authToken: myAuthToken),
          )..add(const LoadWorkers()),
        ),
        BlocProvider(
          create: (context) => TimeSlotsBloc(
            service: TimeSlotService(authToken: myAuthToken),
          )..add(const LoadTimeSlots()),
        ),
      ],
      child: const _ReservationCalendarView(),
    );
  }
}

// Widget interno que maneja el estado
class _ReservationCalendarView extends StatefulWidget {
  const _ReservationCalendarView();

  @override
  State<_ReservationCalendarView> createState() =>
      _ReservationCalendarViewState();
}

class _ReservationCalendarViewState extends State<_ReservationCalendarView> {
  final CalendarController _calendarController = CalendarController();
  CalendarViewType _currentView = CalendarViewType.week;

  // ¡CAMBIO! El valor seleccionado ahora puede ser un Worker o null
  // Usamos null para representar "Horarios generales"
  Worker? _selectedWorker;

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  /// Navega al formulario de crear CITA
  void _openCreateReservationForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ReservationsBloc>()),
            BlocProvider.value(value: context.read<ServicesBloc>()),
            BlocProvider.value(value: context.read<WorkersBloc>()),
            BlocProvider.value(value: context.read<TimeSlotsBloc>()),
          ],
          child: const ReservationFormPage(),
        ),
      ),
    );
  }

  /// Navega al formulario de crear HORARIO
  void _openCreateTimeSlotForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TimeSlotsBloc>(),
          child: const TimeSlotFormPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildViewSwitcher(),
                const Spacer(),
                _buildWorkerFilter(), // ¡Este método ahora es dinámico!
              ],
            ),
          ),
        ),
      ),
      // Usamos un Stack para poner los botones sobre el calendario
      body: Stack(
        children: [
          // 1. El Calendario
          BlocBuilder<ReservationsBloc, ReservationsState>(
            builder: (context, state) {
              if (state.status == Status.loading && state.reservations.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == Status.failure) {
                return Center( /* ... Error ... */ );
              }

              // --- ¡LÓGICA DE FILTRADO! ---
              final allReservations = state.reservations;
              final List<Reservation> reservationsToShow;

              if (_selectedWorker == null) {
                // Si es null ("Horarios generales"), muéstralo todo
                reservationsToShow = allReservations;
              } else {
                // Si hay un trabajador seleccionado, filtra la lista
                reservationsToShow = allReservations.where((res) {
                  return res.workerId.id == _selectedWorker!.id;
                }).toList();
              }
              // --- (fin de la lógica) ---

              return SfCalendar(
                controller: _calendarController,
                dataSource: ReservationDataSource(reservationsToShow), // Pasa la lista filtrada
                view: _getSfCalendarView(_currentView),
                timeSlotViewSettings: const TimeSlotViewSettings(
                  startHour: 9,
                  endHour: 21,
                  nonWorkingDays: <int>[DateTime.sunday],
                  timeFormat: 'HH:mm',
                ),
                monthViewSettings: const MonthViewSettings(
                  showAgenda: true,
                  appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                ),
                headerHeight: 0,
                appointmentBuilder: (context, calendarAppointmentDetails) {
                  final appointment =
                  calendarAppointmentDetails.appointments.first as Appointment;
                  return Container(
                    padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                    decoration: BoxDecoration(
                      color: appointment.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.subject,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            appointment.notes ?? '',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // 2. Botón de crear TimeSlot (Abajo a la izquierda)
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              onPressed: () => _openCreateTimeSlotForm(context),
              heroTag: 'fab_timeslot_page',
              child: const Icon(Icons.schedule),
            ),
          ),

          // 3. Botón de crear Cita (Abajo a la derecha)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => _openCreateReservationForm(context),
              heroTag: 'fab_reservation_page',
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el Dropdown para cambiar de vista (Semana, Día, Mes)
  Widget _buildViewSwitcher() {
    return DropdownButton<CalendarViewType>(
      value: _currentView,
      underline: const SizedBox.shrink(),
      icon: const Icon(Icons.keyboard_arrow_down),
      style: Theme.of(context).textTheme.titleMedium,
      onChanged: (CalendarViewType? newValue) {
        if (newValue == null) return;
        setState(() {
          _currentView = newValue;
          _calendarController.view = _getSfCalendarView(newValue);
        });
      },
      items: const [
        DropdownMenuItem(value: CalendarViewType.week, child: Text('Semanal')),
        DropdownMenuItem(value: CalendarViewType.day, child: Text('Día')),
        DropdownMenuItem(value: CalendarViewType.month, child: Text('Mes')),
      ],
    );
  }

  /// --- ¡MÉTODO ACTUALIZADO! ---
  /// Construye el Dropdown para filtrar por trabajador
  Widget _buildWorkerFilter() {
    // Escucha al WorkersBloc
    return BlocBuilder<WorkersBloc, WorkersState>(
      builder: (context, state) {
        // Maneja los estados de carga y error
        if (state.status != WorkersStatus.success) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Cargando..."),
          );
        }

        // El estado es success, construye la lista de items
        final List<DropdownMenuItem<Worker?>> items = [];

        // 1. Agrega la opción "Horarios generales" (valor null)
        items.add(
          const DropdownMenuItem<Worker?>(
            value: null, // null representa "Horarios generales"
            child: Text("Horarios generales"),
          ),
        );

        // 2. Agrega el resto de trabajadores desde el BLoC
        items.addAll(
          state.workers.map((worker) {
            return DropdownMenuItem<Worker?>(
              value: worker, // El valor es el objeto Worker completo
              child: Text(worker.name),
            );
          }),
        );

        // Devuelve el DropdownButton
        return DropdownButton<Worker?>(
          value: _selectedWorker, // El estado ahora guarda un Worker?
          underline: const SizedBox.shrink(),
          icon: const Icon(Icons.keyboard_arrow_down),
          style: Theme.of(context).textTheme.titleMedium,
          onChanged: (Worker? newWorker) {
            // Actualiza el estado con el nuevo trabajador seleccionado
            setState(() {
              _selectedWorker = newWorker;
            });
            // El BlocBuilder<ReservationsBloc> se reconstruirá automáticamente
            // y filtrará la lista
          },
          items: items, // Usa la lista de items que creamos
        );
      },
    );
  }

  /// Helper para "traducir" nuestro enum al enum del calendario
  CalendarView _getSfCalendarView(CalendarViewType viewType) {
    switch (viewType) {
      case CalendarViewType.day:
        return CalendarView.day;
      case CalendarViewType.week:
        return CalendarView.workWeek;
      case CalendarViewType.month:
        return CalendarView.month;
    }
  }
}