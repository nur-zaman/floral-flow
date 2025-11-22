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
}
