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
                  _showDateActionsDialog(selectedDay, cycleService, fastingService);
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
                    final isPeriod = cycleService.isPeriodDay(date);
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


  void _showDateActionsDialog(DateTime date, CycleService cycleService, FastingService fastingService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log for ${date.month}/${date.day}/${date.year}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.water_drop, color: AppColors.primary),
              title: const Text('Log Missed Fast'),
              onTap: () async {
                await fastingService.logMissedFast(date);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: AppColors.success),
              title: const Text('Log Made Up Fast'),
              onTap: () async {
                await fastingService.logMadeUpFast(date);
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
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
