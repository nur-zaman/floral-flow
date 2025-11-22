import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/fasting_log_model.dart';

class FastingService extends ChangeNotifier {
  static const String boxName = 'fasting_logs';
  late Box<FastingLog> _box;

  FastingService() {
    _box = Hive.box<FastingLog>(boxName);
  }

  List<FastingLog> get logs => _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  int get missedFastsCount => logs.where((l) => l.isMissed).length;
  int get madeUpFastsCount => logs.where((l) => l.isMadeUp).length;
  int get remainingFastsToMakeUp => missedFastsCount - madeUpFastsCount;

  Future<void> logMissedFast(DateTime date, {String reason = 'period'}) async {
    // Check if already logged for this date
    final existing = logs.any((l) => 
      l.date.year == date.year && 
      l.date.month == date.month && 
      l.date.day == date.day
    );
    
    if (!existing) {
      final log = FastingLog(date: date, status: 'missed', reason: reason);
      await _box.add(log);
      notifyListeners();
    }
  }

  Future<void> logMadeUpFast(DateTime date) async {
     // Check if already logged for this date
    final existing = logs.any((l) => 
      l.date.year == date.year && 
      l.date.month == date.month && 
      l.date.day == date.day
    );

    if (!existing) {
      final log = FastingLog(date: date, status: 'made_up');
      await _box.add(log);
      notifyListeners();
    }
  }
  
  Future<void> deleteLog(FastingLog log) async {
    await log.delete();
    notifyListeners();
  }
}
