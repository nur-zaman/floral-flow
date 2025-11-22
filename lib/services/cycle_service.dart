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

  // Simple prediction: Average cycle length or default 28 days
  DateTime get nextPeriodPrediction {
    final lastCycle = cycles.firstOrNull;
    if (lastCycle == null) return DateTime.now();
    
    // TODO: Implement smarter prediction based on history
    return lastCycle.startDate.add(const Duration(days: 28));
  }
}
