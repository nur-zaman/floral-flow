import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/cycle_service.dart';
import '../services/fasting_service.dart';
import '../theme/colors.dart';
import 'fasting_tracker_screen.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Floral Flow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
            },
          ),
        ],
      ),
      body: Consumer2<CycleService, FastingService>(
        builder: (context, cycleService, fastingService, child) {
          final currentCycle = cycleService.currentCycle;
          final isPeriodActive = currentCycle != null;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCycleCard(context, isPeriodActive, cycleService),
                const SizedBox(height: 20),
                _buildFastingSummary(context, fastingService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCycleCard(BuildContext context, bool isPeriodActive, CycleService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              isPeriodActive ? Icons.water_drop : Icons.favorite,
              size: 48,
              color: isPeriodActive ? AppColors.primary : AppColors.secondaryDark,
            ),
            const SizedBox(height: 16),
            Text(
              isPeriodActive ? 'Period Day ${service.currentCycle?.duration}' : 'Period in X Days',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPeriodActive ? 'Take it easy today, sister.' : 'Predicted: ${DateFormat('MMM d').format(service.nextPeriodPrediction)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (isPeriodActive) {
                  service.endCycle(DateTime.now());
                } else {
                  service.startCycle(DateTime.now());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPeriodActive ? AppColors.secondary : AppColors.primary,
              ),
              child: Text(isPeriodActive ? 'Log Period End' : 'Log Period Start'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFastingSummary(BuildContext context, FastingService service) {
    return Card(
      color: AppColors.ramadanGold,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FastingTrackerScreen()));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Missed Fasts',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${service.remainingFastsToMakeUp} pending',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to manage',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.nightlight_round, color: AppColors.primaryDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
