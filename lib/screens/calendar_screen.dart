import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/cycle_service.dart';
import '../services/fasting_service.dart';
import '../theme/colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cycle Calendar'),
      ),
      body: Consumer2<CycleService, FastingService>(
        builder: (context, cycleService, fastingService, child) {
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: AppColors.secondaryDark,
                    shape: BoxShape.circle,
                  ),
                ),
                eventLoader: (day) {
                  // TODO: Return events for the day (Period, Fasting Log)
                  // For now, just returning empty list to avoid errors
                  return [];
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    // Custom markers for Period and Fasting
                    final isPeriod = _isPeriodDay(date, cycleService);
                    final isMissedFast = _isMissedFast(date, fastingService);
                    final isMadeUpFast = _isMadeUpFast(date, fastingService);

                    if (isPeriod) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    if (isMissedFast) {
                       return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                     if (isMadeUpFast) {
                       return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              _buildLegend(),
            ],
          );
        },
      ),
    );
  }

  bool _isPeriodDay(DateTime date, CycleService service) {
    for (final cycle in service.cycles) {
      if (cycle.endDate == null) {
        // Active cycle
        if (date.isAfter(cycle.startDate.subtract(const Duration(days: 1)))) {
           return true;
        }
      } else {
        if (date.isAfter(cycle.startDate.subtract(const Duration(days: 1))) && 
            date.isBefore(cycle.endDate!.add(const Duration(days: 1)))) {
          return true;
        }
      }
    }
    return false;
  }

  bool _isMissedFast(DateTime date, FastingService service) {
    return service.logs.any((l) => 
      l.isMissed && 
      l.date.year == date.year && 
      l.date.month == date.month && 
      l.date.day == date.day
    );
  }

  bool _isMadeUpFast(DateTime date, FastingService service) {
    return service.logs.any((l) => 
      l.isMadeUp && 
      l.date.year == date.year && 
      l.date.month == date.month && 
      l.date.day == date.day
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem('Period', AppColors.primary),
        _legendItem('Missed', AppColors.error),
        _legendItem('Made Up', AppColors.success),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
