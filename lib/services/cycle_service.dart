import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cycle_model.dart';

class CycleService extends ChangeNotifier {
  static const String boxName = 'cycles';
  late Box<Cycle> _box;

  CycleService() {
    _box = Hive.box<Cycle>(boxName);
  }

  List<Cycle> get cycles => _box.values.toList()..sort((a, b) => b.startDate.compareTo(a.startDate));
  
  Cycle? get currentCycle {
    final sorted = cycles;
    if (sorted.isEmpty) return null;
    return sorted.first.isActive ? sorted.first : null;
  }

  Future<void> startCycle(DateTime date) async {
    // If there's an active cycle, end it first (assuming it ended the day before this one starts)
    if (currentCycle != null) {
      await endCycle(date.subtract(const Duration(days: 1)));
    }
    
    final newCycle = Cycle(startDate: date);
    await _box.add(newCycle);
    notifyListeners();
  }

  Future<void> endCycle(DateTime date) async {
    final cycle = currentCycle;
    if (cycle != null) {
      cycle.endDate = date;
      await cycle.save();
      notifyListeners();
    }
  }

  Future<void> deleteCycle(Cycle cycle) async {
    await cycle.delete();
    notifyListeners();
  }

  // Calculate average cycle length (days between start dates)
  int get averageCycleLength {
    if (cycles.length < 2) return 28;
    
    int totalDays = 0;
    int gaps = 0;
    
    for (int i = 0; i < cycles.length - 1; i++) {
      final current = cycles[i];
      final previous = cycles[i + 1];
      final diff = current.startDate.difference(previous.startDate).inDays;
      // Filter out unreasonable outliers (e.g. > 60 days might be missed cycles)
      if (diff > 10 && diff < 60) {
        totalDays += diff;
        gaps++;
      }
    }
    
    if (gaps == 0) return 28;
    return (totalDays / gaps).round();
  }

  // Calculate average period duration (days of bleeding)
  int get averagePeriodDuration {
    final closedCycles = cycles.where((c) => c.endDate != null).toList();
    if (closedCycles.isEmpty) return 5; // Default to 5 days
    
    int totalDuration = 0;
    for (final cycle in closedCycles) {
      totalDuration += cycle.duration;
    }
    
    return (totalDuration / closedCycles.length).round();
  }

  Future<void> logPastCycle({required DateTime startDate, required DateTime endDate}) async {
    final newCycle = Cycle(startDate: startDate, endDate: endDate);
    await _box.add(newCycle);
    notifyListeners();
  }

  bool isPeriodDay(DateTime date) {
    // Normalize date to start of day
    final checkDate = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final cycle in cycles) {
      final start = DateTime(cycle.startDate.year, cycle.startDate.month, cycle.startDate.day);
      
      if (cycle.endDate != null) {
        final end = DateTime(cycle.endDate!.year, cycle.endDate!.month, cycle.endDate!.day);
        if ((checkDate.isAtSameMomentAs(start) || checkDate.isAfter(start)) && 
            (checkDate.isAtSameMomentAs(end) || checkDate.isBefore(end))) {
          return true;
        }
      } else {
        // Active cycle: Only mark up to today
        if ((checkDate.isAtSameMomentAs(start) || checkDate.isAfter(start)) && 
            (checkDate.isAtSameMomentAs(today) || checkDate.isBefore(today))) {
          return true;
        }
      }
    }
    return false;
  }

  DateTime get nextPeriodPrediction {
    final lastCycle = cycles.firstOrNull;
    if (lastCycle == null) return DateTime.now();
    
    return lastCycle.startDate.add(Duration(days: averageCycleLength));
  }
}
