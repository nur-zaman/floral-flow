import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'models/cycle_model.dart';
import 'models/fasting_log_model.dart';
import 'services/cycle_service.dart';
import 'services/fasting_service.dart';
import 'screens/home_screen.dart';

void main() async {
  // Initialize Hive
  await Hive.initFlutter(); 
  
  // Register Adapters
  Hive.registerAdapter(CycleAdapter());
  Hive.registerAdapter(FastingLogAdapter());
  
  // Open Boxes
  await Hive.openBox<Cycle>(CycleService.boxName);
  await Hive.openBox<FastingLog>(FastingService.boxName);

  runApp(const PeriodRamadanApp());
}

class PeriodRamadanApp extends StatelessWidget {
  const PeriodRamadanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CycleService()),
        ChangeNotifierProvider(create: (_) => FastingService()),
      ],
      child: MaterialApp(
        title: 'Floral Flow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
