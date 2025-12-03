import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/features/calendar/data/calendar_service.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_bloc.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_event.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_state.dart';
import 'package:iosmobileapp/features/reviews/data/client_service.dart';
import 'package:intl/intl.dart';
import 'package:calendar_day_view/calendar_day_view.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late DateTime _selectedDate;
  DateTime _selectedMonth = DateTime.now(); // Mes seleccionado
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Inicializar con el día actual
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _selectedMonth = DateTime(now.year, now.month);
    
    // Hacer scroll al día actual después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _scrollToToday() {
    final now = DateTime.now();
    if (_horizontalScrollController.hasClients && 
        _selectedMonth.year == now.year && 
        _selectedMonth.month == now.month) {
      // Calcular la posición del día actual en el scroll
      final todayIndex = now.day - 1; // Los días empiezan en 1, el índice en 0
      final itemWidth = 60.0 + 8.0; // Ancho del item + margen
      final scrollPosition = todayIndex * itemWidth;
      _horizontalScrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToSelectedDate() {
    if (_horizontalScrollController.hasClients &&
        _selectedDate.month == _selectedMonth.month &&
        _selectedDate.year == _selectedMonth.year) {
      // Calcular la posición del día seleccionado en el scroll
      final selectedIndex = _selectedDate.day - 1; // Los días empiezan en 1, el índice en 0
      final itemWidth = 60.0 + 8.0; // Ancho del item + margen
      final scrollPosition = selectedIndex * itemWidth;
      _horizontalScrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Obtener los próximos 2 meses desde el mes actual (no del seleccionado)
  List<DateTime> _getAvailableMonths() {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    
    return [
      DateTime(currentYear, currentMonth), // Mes actual
      DateTime(currentYear, currentMonth + 1), // Siguiente mes
      DateTime(currentYear, currentMonth + 2), // Mes +2
    ];
  }

  void _showMonthSelector() {
    final availableMonths = _getAvailableMonths();
    final now = DateTime.now();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Seleccionar mes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...availableMonths.map((month) {
              final isSelected = month.year == _selectedMonth.year &&
                  month.month == _selectedMonth.month;
              final isCurrentMonth = month.year == now.year &&
                  month.month == now.month;
              
              return ListTile(
                title: Text(
                  _getMonthName(month),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFF7209B7)
                        : Colors.black87,
                  ),
                ),
                trailing: isCurrentMonth
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7209B7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Actual',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7209B7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _selectedMonth = month;
                    final now = DateTime.now();
                    // Si el mes seleccionado es el mes actual, seleccionar el día actual
                    // Si no, seleccionar el día 1 del mes
                    if (month.year == now.year && month.month == now.month) {
                      _selectedDate = DateTime(now.year, now.month, now.day);
                    } else {
                      _selectedDate = DateTime(month.year, month.month, 1);
                    }
                  });
                  Navigator.pop(context);
                  // Recargar reservas del nuevo mes
                  final monthStart = DateTime(month.year, month.month, 1);
                  final monthEnd = DateTime(month.year, month.month + 1, 0);
                  context.read<ReservationsBloc>().add(GetReservationsByRange(
                    startDate: monthStart,
                    endDate: monthEnd,
                  ));
                  // Hacer scroll al día seleccionado
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToSelectedDate();
                  });
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getMonthName(DateTime month) {
    try {
      return DateFormat('MMMM', 'es').format(month);
    } catch (e) {
      // Fallback si hay error con el formato
      final months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      return months[month.month - 1];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cargar reservas del mes seleccionado
    final monthStart = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final monthEnd = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    
    return BlocProvider(
      create: (context) => ReservationsBloc(service: CalendarService())
        ..add(GetReservationsByRange(
          startDate: monthStart,
          endDate: monthEnd,
        )),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: GestureDetector(
            onTap: _showMonthSelector,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getMonthName(_selectedMonth),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7209B7),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF7209B7),
                  size: 24,
                ),
              ],
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            BlocBuilder<ReservationsBloc, ReservationsState>(
              builder: (context, state) {
                return IconButton(
                  icon: state.status == Status.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7209B7)),
                          ),
                        )
                      : const Icon(Icons.refresh, color: Color(0xFF7209B7)),
                  onPressed: state.status == Status.loading
                      ? null
                      : () {
                          // Refrescar reservas del mes seleccionado
                          final monthStart = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
                          final monthEnd = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
                          context.read<ReservationsBloc>().add(GetReservationsByRange(
                            startDate: monthStart,
                            endDate: monthEnd,
                          ));
                        },
                );
              },
            ),
          ],
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

            return Column(
              children: [
                // Calendario horizontal
                _WeekCalendar(
                  selectedDate: _selectedDate,
                  selectedMonth: _selectedMonth,
                  scrollController: _horizontalScrollController,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                      // Si cambió el mes, recargar reservas
                      if (date.month != _selectedMonth.month || 
                          date.year != _selectedMonth.year) {
                        _selectedMonth = DateTime(date.year, date.month);
                        final monthStart = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
                        final monthEnd = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
                        context.read<ReservationsBloc>().add(GetReservationsByRange(
                          startDate: monthStart,
                          endDate: monthEnd,
                        ));
                      }
                    });
                    // Hacer scroll al día seleccionado
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToSelectedDate();
                    });
                  },
                ),
                // Vista del timeline
                Expanded(
                  child: _TimelineView(
                    selectedDate: _selectedDate,
                    reservations: state.reservations,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WeekCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime selectedMonth;
  final Function(DateTime) onDateSelected;
  final ScrollController scrollController;

  const _WeekCalendar({
    required this.selectedDate,
    required this.selectedMonth,
    required this.onDateSelected,
    required this.scrollController,
  });

  String _getDayName(DateTime date) {
    try {
      return DateFormat('E', 'es').format(date).substring(0, 3);
    } catch (e) {
      final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return days[date.weekday - 1];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener todos los días del mes seleccionado
    final monthEnd = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    final daysInMonth = monthEnd.day;
    
    final days = List.generate(daysInMonth, (index) {
      return DateTime(selectedMonth.year, selectedMonth.month, index + 1);
    });

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          final isToday = date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day;

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF7209B7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isToday ? const Color(0xFF7209B7) : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isToday ? const Color(0xFF7209B7) : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimelineView extends StatelessWidget {
  final DateTime selectedDate;
  final List<Reservation> reservations;

  const _TimelineView({
    required this.selectedDate,
    required this.reservations,
  });

  @override
  Widget build(BuildContext context) {
    // Filtrar reservas del día seleccionado
    final dayReservations = reservations.where((reservation) {
      try {
        final reservationDate = reservation.timeSlot.startTime;
        return reservationDate.year == selectedDate.year &&
            reservationDate.month == selectedDate.month &&
            reservationDate.day == selectedDate.day;
      } catch (e) {
        return false;
      }
    }).toList();

    // Colores alternados para diferentes eventos
    final colors = [
      const Color(0xFF7209B7),
      const Color(0xFF9D4EDD),
      Colors.orange.shade400,
      Colors.blue.shade400,
      Colors.pink.shade400,
    ];

    // Convertir reservas a eventos del calendario
    final List<DayEvent<Reservation>> events = dayReservations.map((reservation) {
      return DayEvent<Reservation>(
        value: reservation,
        start: reservation.timeSlot.startTime,
        end: reservation.timeSlot.endTime,
        name: reservation.serviceId.name,
      );
    }).toList();

    // Calcular heightPerMin dinámicamente basado en todas las reservas del día
    // Para cada reserva, calculamos cuántos píxeles necesita y usamos el máximo
    // Esto asegura que todas las reservas quepan, sin importar su duración (25min, 45min, etc.)
    double heightPerMin = 1.0; // Valor por defecto cuando no hay reservas
    
    if (events.isNotEmpty) {
      // Altura mínima necesaria para mostrar toda la información de una reserva
      // Servicio (11px) + espacios (4px) + hora (8px) + espacios (4px) + 
      // trabajador (15px) + espacios (4px) + cliente (15px) + padding (8px) = ~69px
      const double minHeightForFullInfo = 69.0;
      
      // Para cada reserva, calcular el heightPerMin necesario
      double maxHeightPerMin = 0.0;
      
      for (final event in events) {
        final start = event.start;
        final end = event.end;
        
        // Verificar que start y end no sean null
        if (start != null && end != null) {
          final duration = end.difference(start);
          final durationMinutes = duration.inMinutes;
          
          if (durationMinutes > 0) {
            // Calcular cuántos píxeles por minuto necesita esta reserva
            final requiredHeightPerMin = minHeightForFullInfo / durationMinutes;
            if (requiredHeightPerMin > maxHeightPerMin) {
              maxHeightPerMin = requiredHeightPerMin;
            }
          }
        }
      }
      
      // Usar el máximo encontrado, con un mínimo de 2.0 para reservas muy largas
      // y un máximo de 3.5 para evitar que el calendario sea demasiado grande
      heightPerMin = maxHeightPerMin.clamp(2.0, 3.5);
    }

    return CalendarDayView.overflow(
      config: OverFlowDayViewConfig(
        currentDate: selectedDate,
        timeGap: 30, // Intervalo de 30 minutos
        heightPerMin: heightPerMin, // Espacio dinámico: más grande si hay reservas
        endOfDay: const TimeOfDay(hour: 23, minute: 59),
        startOfDay: const TimeOfDay(hour: 0, minute: 0),
        renderRowAsListView: true,
        time12: false, // Formato de 24 horas
        dividerColor: const Color(0xFF7209B7).withOpacity(0.2), // Líneas moradas
      ),
      onTimeTap: (time) {
        // Acción al tocar en un intervalo de tiempo (opcional)
      },
      events: events,
      overflowItemBuilder: (context, constraints, itemIndex, event) {
        // Obtener la reserva desde el value del evento
        final reservation = event.value;
        final color = colors[itemIndex % colors.length];

        return _ReservationBlock(
          reservation: reservation,
          color: color,
        );
      },
    );
  }
}

class _ReservationBlock extends StatefulWidget {
  final Reservation reservation;
  final Color color;

  const _ReservationBlock({
    required this.reservation,
    required this.color,
  });

  @override
  State<_ReservationBlock> createState() => _ReservationBlockState();
}

class _ReservationBlockState extends State<_ReservationBlock> {
  String? _clientName;
  bool _isLoadingClient = true;

  @override
  void initState() {
    super.initState();
    _loadClientName();
  }

  Future<void> _loadClientName() async {
    try {
      final clientService = ClientService();
      final clientInfo = await clientService.getClientById(widget.reservation.clientId);
      if (mounted) {
        setState(() {
          _clientName = clientInfo.fullName;
          _isLoadingClient = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _clientName = 'Cliente #${widget.reservation.clientId}';
          _isLoadingClient = false;
        });
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    // Formato 24 horas: HH:mm
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final startTime = widget.reservation.timeSlot.startTime;
    final endTime = widget.reservation.timeSlot.endTime;

    // Calcular la duración real de la reserva
    final duration = endTime.difference(startTime);
    final durationMinutes = duration.inMinutes;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Ajustar el contenido según el espacio disponible
          final availableHeight = constraints.maxHeight;
          
          // Calcular altura mínima necesaria para mostrar todo el contenido
          // Servicio (11px) + espacio (3px) + hora (7px) + espacio (3px) + 
          // trabajador (15px) + espacio (3px) + cliente (15px) = ~57px
          final minHeightNeeded = 57.0;
          final canShowAll = availableHeight >= minHeightNeeded;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Nombre del servicio
              Text(
                widget.reservation.serviceId.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (canShowAll) ...[
                const SizedBox(height: 4),
                // Hora
                Text(
                  '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                // Trabajador
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.content_cut,
                      size: 9,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.reservation.workerId.name,
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Cliente
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      size: 9,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: _isLoadingClient
                          ? SizedBox(
                              width: 8,
                              height: 8,
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.9),
                                ),
                              ),
                            )
                          : Text(
                              _clientName ?? 'Cliente #${widget.reservation.clientId}',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                                height: 1.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ],
                ),
              ] else ...[
                // Si no hay espacio suficiente, mostrar solo lo esencial
                const SizedBox(height: 2),
                Text(
                  '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                  style: TextStyle(
                    fontSize: 7,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.0,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
