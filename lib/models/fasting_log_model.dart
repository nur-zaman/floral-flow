import 'package:hive/hive.dart';

part 'fasting_log_model.g.dart';

@HiveType(typeId: 1)
class FastingLog extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String status; // 'missed', 'made_up', 'completed'

  @HiveField(2)
  final String? reason; // 'period', 'sick', 'travel', etc.

  FastingLog({
    required this.date,
    required this.status,
    this.reason,
  });
  
  bool get isMissed => status == 'missed';
  bool get isMadeUp => status == 'made_up';
}
