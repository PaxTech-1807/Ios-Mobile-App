import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iosmobileapp/features/calendar/data/calendar_service.dart';
import 'package:iosmobileapp/features/calendar/domain/reservation.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_bloc.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_event.dart';
import 'package:iosmobileapp/features/calendar/presentation/blocs/reservations_state.dart';
import 'package:iosmobileapp/features/reviews/data/client_service.dart';
import 'package:intl/intl.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedMonth = DateTime.now(); // Mes seleccionado
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
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
                            fontSize: 11,
                            color: Color(0xFF7209B7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _selectedMonth = month;
                    // Actualizar la fecha seleccionada al primer día del mes seleccionado
                    _selectedDate = DateTime(month.year, month.month, 1);
                  });
                  Navigator.pop(context);
                  // Recargar reservas del nuevo mes
                  final monthStart = DateTime(month.year, month.month, 1);
                  final monthEnd = DateTime(month.year, month.month + 1, 0);
                  context.read<ReservationsBloc>().add(GetReservationsByRange(
                    startDate: monthStart,
                    endDate: monthEnd,
                  ));
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                      // Si cambió el mes, recargar reservas
                      if (date.month != _selectedMonth.month || 
                          date.year != _selectedMonth.year) {
                        _selectedMonth = DateTime(date.year, date.month);
                        final monthStart = DateTime(date.year, date.month, 1);
                        final monthEnd = DateTime(date.year, date.month + 1, 0);
                        context.read<ReservationsBloc>().add(GetReservationsByRange(
                          startDate: monthStart,
                          endDate: monthEnd,
                        ));
                      }
                    });
                  },
                  scrollController: _horizontalScrollController,
                ),
                const SizedBox(height: 8),
                // Timeline con reservas
                Expanded(
                  child: _TimelineView(
                    selectedDate: _selectedDate,
                    reservations: state.reservations, // Data real de la API
                    scrollController: _verticalScrollController,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getMonthName(DateTime date) {
    try {
      final monthName = DateFormat('MMMM', 'es').format(date);
      // Capitalizar primera letra
      return monthName[0].toUpperCase() + monthName.substring(1);
    } catch (e) {
      // Fallback si hay error con el formato
      const months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      return months[date.month - 1];
    }
  }
}

class _WeekCalendar extends StatefulWidget {
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

  @override
  State<_WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<_WeekCalendar> {
  @override
  void initState() {
    super.initState();
    // Scroll a la fecha seleccionada después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void didUpdateWidget(_WeekCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMonth.month != oldWidget.selectedMonth.month ||
        widget.selectedMonth.year != oldWidget.selectedMonth.year) {
      // Mes cambió, scroll al inicio del mes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate();
      });
    } else if (!_isSameDay(widget.selectedDate, oldWidget.selectedDate)) {
      _scrollToSelectedDate();
    }
  }

  void _scrollToSelectedDate() {
    if (!widget.scrollController.hasClients) return;
    
    final monthStart = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, 1);
    final daysDifference = widget.selectedDate.difference(monthStart).inDays;
    
    // Calcular posición de scroll (cada día = 58px)
    final scrollPosition = (daysDifference * 58.0);
    widget.scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Obtener el inicio de la semana (domingo) usando DateTime real
  DateTime _getWeekStart(DateTime date) {
    // DateTime.weekday: 1 = lunes, 7 = domingo
    // Necesitamos domingo como inicio de semana
    final weekday = date.weekday; // 1-7
    final daysFromSunday = weekday == 7 ? 0 : weekday;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromSunday));
  }

  // Generar todos los días del mes seleccionado (reales, usando DateTime)
  List<DateTime> _generateAllDays() {
    final year = widget.selectedMonth.year;
    final month = widget.selectedMonth.month;
    
    // Obtener el primer día del mes
    final firstDay = DateTime(year, month, 1);
    // Obtener el último día del mes (DateTime maneja automáticamente días del mes)
    final lastDay = DateTime(year, month + 1, 0);
    
    final days = <DateTime>[];
    var currentDate = firstDay;
    
    // DateTime maneja automáticamente:
    // - Días del mes (28, 29, 30, 31)
    // - Años bisiestos
    while (currentDate.isBefore(lastDay) || currentDate.isAtSameMomentAs(lastDay)) {
      days.add(DateTime(currentDate.year, currentDate.month, currentDate.day));
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return days;
  }

  @override
  Widget build(BuildContext context) {
    // Obtener todos los días reales usando DateTime
    final allDays = _generateAllDays();
    final now = DateTime.now(); // Fecha actual real del dispositivo

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: allDays.map((date) {
            // Usar DateTime real para comparaciones
            final isSelected = _isSameDay(date, widget.selectedDate);
            final isToday = _isSameDay(date, now);
            
            return GestureDetector(
              onTap: () => widget.onDateSelected(date),
              child: Container(
                width: 50,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF7209B7)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getDayName(date.weekday),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isToday && !isSelected
                            ? const Color(0xFF7209B7).withOpacity(0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isToday && !isSelected
                            ? Border.all(
                                color: const Color(0xFF7209B7),
                                width: 2,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}', // Día real del mes
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? const Color(0xFF7209B7)
                                    : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDayName(int weekday) {
    // weekday: 1 = lunes, 7 = domingo
    // Necesitamos: 0 = domingo, 1 = lunes, ..., 6 = sábado
    const days = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    final index = weekday == 7 ? 0 : weekday;
    return days[index];
  }
}

class _TimelineView extends StatefulWidget {
  final DateTime selectedDate;
  final List<Reservation> reservations;
  final ScrollController scrollController;

  const _TimelineView({
    required this.selectedDate,
    required this.reservations,
    required this.scrollController,
  });

  @override
  State<_TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<_TimelineView> {
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Actualizar hora actual cada minuto
    _updateCurrentTime();
  }

  void _updateCurrentTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateTime.now();
      });
      Future.delayed(const Duration(minutes: 1), _updateCurrentTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayReservations = widget.reservations.where((reservation) {
      try {
        final reservationDate = reservation.timeSlot.startTime;
        return reservationDate.year == widget.selectedDate.year &&
            reservationDate.month == widget.selectedDate.month &&
            reservationDate.day == widget.selectedDate.day;
      } catch (e) {
        return false;
      }
    }).toList();

    // Organizar reservas en columnas para evitar superposición
    final columns = _organizeReservationsIntoColumns(dayReservations);

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Timeline scrollable (vertical y horizontal)
          SingleChildScrollView(
            controller: widget.scrollController,
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna de horas (intervalos de 30 minutos, 60px por hora)
                  Container(
                    width: 60,
                    child: Column(
                      children: List.generate(48, (index) {
                        final hour = index ~/ 2;
                        final minute = (index % 2) * 30;
                        final showLabel = minute == 0; // Solo mostrar etiqueta en horas completas
                        
                        return Container(
                          height: 60, // 60px por hora (30px por cada intervalo de 30 minutos)
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 8, top: 0),
                          decoration: minute == 0
                              ? BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                  ),
                                )
                              : null,
                          child: showLabel
                              ? Text(
                                  '${hour.toString().padLeft(2, '0')}:00',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        );
                      }),
                    ),
                  ),
                  // Área de reservas (scrollable en ambas direcciones)
                  SizedBox(
                    width: columns.isEmpty 
                        ? 400 
                        : (columns.length * 120.0).clamp(400.0, double.infinity),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final availableWidth = constraints.maxWidth;
                        return Stack(
                          children: [
                            // Líneas de tiempo (intervalos de 30 minutos, 60px por hora)
                            Column(
                              children: List.generate(48, (index) {
                                final isHour = (index % 2) == 0; // Línea más gruesa cada hora
                                return Container(
                                  height: 60, // 60px por hora (30px por cada intervalo de 30 minutos)
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isHour
                                            ? Colors.grey.shade300
                                            : Colors.grey.shade200,
                                        width: isHour ? 1.0 : 0.5,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            // Reservas organizadas en columnas
                            ...columns.asMap().entries.expand((entry) {
                              final columnIndex = entry.key;
                              final reservations = entry.value;
                              return reservations.map((reservation) {
                                return _ReservationBlock(
                                  reservation: reservation,
                                  columnIndex: columnIndex,
                                  totalColumns: columns.length,
                                  availableWidth: availableWidth,
                                );
                              });
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Indicador de hora actual (fijo sobre toda la pantalla)
          if (_isSameDay(widget.selectedDate, _currentTime))
            _CurrentTimeIndicator(
              currentTime: _currentTime,
              intervalHeight: 30.0,
              leftOffset: 60.0, // Offset para alinear con la columna de horas
            ),
        ],
      ),
    );
  }

  List<List<Reservation>> _organizeReservationsIntoColumns(
    List<Reservation> reservations,
  ) {
    if (reservations.isEmpty) return [];

    // Ordenar por hora de inicio
    final sorted = List<Reservation>.from(reservations)
      ..sort((a, b) => a.timeSlot.startTime.compareTo(b.timeSlot.startTime));

    final columns = <List<Reservation>>[];

    for (final reservation in sorted) {
      bool placed = false;
      for (final column in columns) {
        // Verificar si no hay superposición con las reservas en esta columna
        final hasOverlap = column.any((existing) {
          return _hasTimeOverlap(
            reservation.timeSlot.startTime,
            reservation.timeSlot.endTime,
            existing.timeSlot.startTime,
            existing.timeSlot.endTime,
          );
        });

        if (!hasOverlap) {
          column.add(reservation);
          placed = true;
          break;
        }
      }

      if (!placed) {
        // Crear nueva columna
        columns.add([reservation]);
      }
    }

    return columns;
  }

  bool _hasTimeOverlap(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class _ReservationBlock extends StatelessWidget {
  final Reservation reservation;
  final int columnIndex;
  final int totalColumns;
  final double availableWidth;

  const _ReservationBlock({
    required this.reservation,
    required this.columnIndex,
    required this.totalColumns,
    required this.availableWidth,
  });

  Future<String> _getClientName(int clientId) async {
    try {
      final clientService = ClientService();
      final clientInfo = await clientService.getClientById(clientId);
      return clientInfo.fullName;
    } catch (e) {
      return 'Cliente #$clientId';
    }
  }

  @override
  Widget build(BuildContext context) {
    final startTime = reservation.timeSlot.startTime;
    final endTime = reservation.timeSlot.endTime;
    
    // Calcular posición y altura basado en intervalos de 30 minutos
    // Cada intervalo de 30 minutos = 30px, cada hora = 60px
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final durationMinutes = endMinutes - startMinutes;
    
    final top = (startMinutes / 30.0) * 30.0; // Posición en píxeles
    final height = (durationMinutes / 30.0) * 30.0; // Altura en píxeles

    // Colores alternados para diferentes columnas
    final colors = [
      const Color(0xFF7209B7),
      const Color(0xFF9D4EDD),
      Colors.orange.shade400,
      Colors.blue.shade400,
      Colors.pink.shade400,
    ];
    final color = colors[columnIndex % colors.length];

    // Ancho de la columna (ajustar según el número de columnas)
    final columnWidth = totalColumns > 1 ? (availableWidth / totalColumns) : availableWidth;
    final left = columnIndex * columnWidth;

    return Positioned(
      left: left,
      top: top,
      width: columnWidth - 4,
      height: height,
      child: Container(
        margin: const EdgeInsets.only(right: 4, top: 2, bottom: 2),
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nombre del servicio
              Text(
                reservation.serviceId.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Hora
              Text(
                '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 6),
              // Trabajador
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      reservation.workerId.name,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
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
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _getClientName(reservation.clientId),
                      builder: (context, snapshot) {
                        final clientName = snapshot.data ?? 'Cliente #${reservation.clientId}';
                        return Text(
                          clientName,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    final displayHour = dateTime.hour > 12
        ? (dateTime.hour - 12).toString()
        : dateTime.hour == 0
            ? '12'
            : dateTime.hour.toString();
    return '$displayHour:$minute $period';
  }
}

class _CurrentTimeIndicator extends StatelessWidget {
  final DateTime currentTime;
  final double intervalHeight;
  final double leftOffset;

  const _CurrentTimeIndicator({
    required this.currentTime,
    required this.intervalHeight,
    this.leftOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular posición basada en intervalos de 30 minutos
    // Cada intervalo de 30 minutos = 30px, cada hora = 60px
    final totalMinutes = currentTime.hour * 60 + currentTime.minute;
    final top = (totalMinutes / 30.0) * 30.0; // 30px por cada intervalo de 30 minutos

    return Positioned(
      left: leftOffset,
      right: 0,
      top: top,
      child: IgnorePointer(
        child: Row(
          children: [
            // Punto indicador (alineado con la columna de horas)
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(left: 48), // 60px (ancho columna) - 12px (ancho punto) = 48px
              decoration: BoxDecoration(
                color: const Color(0xFF7209B7),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7209B7).withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Línea horizontal
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7209B7),
                      const Color(0xFF7209B7).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
