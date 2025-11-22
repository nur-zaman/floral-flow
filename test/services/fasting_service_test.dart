import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_modern_template/models/fasting_log_model.dart';
import 'package:flutter_modern_template/services/fasting_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FastingLogAdapter());
    }
    await Hive.openBox<FastingLog>(FastingService.boxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('FastingService starts with zero counts', () {
    final service = FastingService();
    expect(service.missedFastsCount, 0);
    expect(service.madeUpFastsCount, 0);
    expect(service.remainingFastsToMakeUp, 0);
  });

  test('FastingService logs missed fast', () async {
    final service = FastingService();
    final date = DateTime(2023, 3, 23); // Ramadan date
    
    await service.logMissedFast(date);
    
    expect(service.missedFastsCount, 1);
    expect(service.remainingFastsToMakeUp, 1);
    expect(service.logs.first.isMissed, isTrue);
  });

  test('FastingService logs made up fast', () async {
    final service = FastingService();
    final date = DateTime(2023, 4, 25);
    
    await service.logMissedFast(DateTime(2023, 3, 23)); // Miss one first
    await service.logMadeUpFast(date);
    
    expect(service.missedFastsCount, 1);
    expect(service.madeUpFastsCount, 1);
    expect(service.remainingFastsToMakeUp, 0);
  });

  test('FastingService prevents duplicate logs for same day', () async {
    final service = FastingService();
    final date = DateTime(2023, 3, 23);
    
    await service.logMissedFast(date);
    await service.logMissedFast(date); // Try logging again
    
    expect(service.logs.length, 1);
  });
}
