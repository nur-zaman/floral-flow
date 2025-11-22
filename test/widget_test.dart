import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_modern_template/main.dart';
import 'package:flutter_modern_template/models/cycle_model.dart';
import 'package:flutter_modern_template/models/fasting_log_model.dart';
import 'package:flutter_modern_template/services/cycle_service.dart';
import 'package:flutter_modern_template/services/fasting_service.dart';
import 'package:flutter_modern_template/theme/app_theme.dart';
import 'package:flutter_modern_template/screens/home_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CycleAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FastingLogAdapter());
    }
    await Hive.openBox<Cycle>(CycleService.boxName);
    await Hive.openBox<FastingLog>(FastingService.boxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  testWidgets('HomeScreen loads and shows title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CycleService()),
          ChangeNotifierProvider(create: (_) => FastingService()),
        ],
        child: MaterialApp(
          title: 'Floral Flow',
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );

    // Verify that our title is present.
    expect(find.text('Floral Flow'), findsOneWidget);
    expect(find.text('Missed Fasts'), findsOneWidget);
    
    // Verify initial state
    expect(find.text('0 pending'), findsOneWidget);
  });
}
