import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_modern_template/models/cycle_model.dart';
import 'package:flutter_modern_template/services/cycle_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CycleAdapter());
    }
    await Hive.openBox<Cycle>(CycleService.boxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('CycleService starts with empty cycles', () {
    final service = CycleService();
    expect(service.cycles, isEmpty);
    expect(service.currentCycle, isNull);
  });

  test('CycleService can start a cycle', () async {
    final service = CycleService();
    final now = DateTime.now();
    
    await service.startCycle(now);
    
    expect(service.cycles.length, 1);
    expect(service.currentCycle, isNotNull);
    expect(service.currentCycle!.startDate, now);
    expect(service.currentCycle!.isActive, isTrue);
  });

  test('CycleService ends current cycle when starting a new one', () async {
    final service = CycleService();
    final date1 = DateTime(2023, 1, 1);
    final date2 = DateTime(2023, 2, 1);
    
    await service.startCycle(date1);
    expect(service.currentCycle!.isActive, isTrue);
    
    await service.startCycle(date2);
    
    expect(service.cycles.length, 2);
    // The first cycle should be ended
    final firstCycle = service.cycles.last; // sorted by date desc, so last is oldest
    expect(firstCycle.endDate, isNotNull);
    expect(firstCycle.isActive, isFalse);
    
    // The new cycle should be active
    expect(service.currentCycle!.startDate, date2);
    expect(service.currentCycle!.isActive, isTrue);
  });

  test('CycleService can manually end a cycle', () async {
    final service = CycleService();
    final start = DateTime(2023, 1, 1);
    final end = DateTime(2023, 1, 5);
    
    await service.startCycle(start);
    await service.endCycle(end);
    
    expect(service.currentCycle, isNull);
    expect(service.cycles.first.endDate, end);
    expect(service.cycles.first.duration, 5);
  });

  test('CycleService calculates average cycle length', () async {
    final service = CycleService();
    // Cycle 1: Jan 1 -> Feb 1 (31 days)
    await service.startCycle(DateTime(2023, 1, 1));
    await service.startCycle(DateTime(2023, 2, 1));
    
    // Cycle 2: Feb 1 -> Mar 1 (28 days)
    await service.startCycle(DateTime(2023, 3, 1));
    
    // Average: (31 + 28) / 2 = 29.5 -> 30 days (round)
    expect(service.averageCycleLength, 30);
  });

  test('CycleService calculates average period duration', () async {
    final service = CycleService();
    
    // Period 1: 5 days
    await service.startCycle(DateTime(2023, 1, 1));
    await service.endCycle(DateTime(2023, 1, 5));
    
    // Period 2: 7 days
    await service.startCycle(DateTime(2023, 2, 1));
    await service.endCycle(DateTime(2023, 2, 7));
    
    // Average: (5 + 7) / 2 = 6 days
    expect(service.averagePeriodDuration, 6);
  });

  test('CycleService predicts next period based on average', () async {
    final service = CycleService();
    
    // Setup history for 30 day average
    await service.startCycle(DateTime(2023, 1, 1));
    await service.startCycle(DateTime(2023, 1, 31)); // 30 days
    
    // Last cycle started Jan 31. Next should be +30 days = Mar 2 (non-leap)
    // Jan 31 + 30 days = March 2nd.
    expect(service.nextPeriodPrediction, DateTime(2023, 3, 2));
  });

  test('CycleService allows logging past cycles', () async {
    final service = CycleService();
    final pastDate = DateTime(2022, 1, 1);
    
    await service.logPastCycle(
      startDate: pastDate, 
      endDate: DateTime(2022, 1, 5)
    );
    
    expect(service.cycles.length, 1);
    expect(service.cycles.first.startDate, pastDate);
    expect(service.cycles.first.endDate, DateTime(2022, 1, 5));
    // Should not be current cycle if it ended
    expect(service.currentCycle, isNull);
  });

  test('CycleService checks if date is period day', () async {
    final service = CycleService();
    final today = DateTime.now();
    
    // Start cycle today
    await service.startCycle(today);
    
    expect(service.isPeriodDay(today), isTrue);
    // Future days should NOT be marked as period day for "active" cycle
    expect(service.isPeriodDay(today.add(const Duration(days: 1))), isFalse);
    
    // Past closed cycle
    final pastStart = DateTime(2022, 1, 1);
    final pastEnd = DateTime(2022, 1, 5);
    await service.logPastCycle(startDate: pastStart, endDate: pastEnd);
    
    expect(service.isPeriodDay(pastStart), isTrue);
    expect(service.isPeriodDay(DateTime(2022, 1, 3)), isTrue);
    expect(service.isPeriodDay(pastEnd), isTrue);
    expect(service.isPeriodDay(DateTime(2022, 1, 6)), isFalse);
  });
}
