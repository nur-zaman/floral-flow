import 'package:hive/hive.dart';

part 'cycle_model.g.dart';

@HiveType(typeId: 0)
class Cycle extends HiveObject {
  @HiveField(0)
  final DateTime startDate;

  @HiveField(1)
  DateTime? endDate;

  @HiveField(2)
  String? notes;

  @HiveField(3)
  int? flowIntensity; // 1: Light, 2: Medium, 3: Heavy

  Cycle({
    required this.startDate,
    this.endDate,
    this.notes,
    this.flowIntensity,
  });

  int get duration => endDate != null 
      ? endDate!.difference(startDate).inDays + 1 
      : 0;

  bool get isActive => endDate == null;
}
