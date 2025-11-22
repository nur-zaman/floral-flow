import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/fasting_service.dart';
import '../theme/colors.dart';
import '../widgets/flower_progress.dart';

class FastingTrackerScreen extends StatelessWidget {
  const FastingTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fasting Tracker'),
      ),
      body: Consumer<FastingService>(
        builder: (context, service, child) {
          final totalMissed = service.missedFastsCount;
          final totalMadeUp = service.madeUpFastsCount;
          
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              FlowerProgressWidget(
                completed: totalMadeUp,
                total: totalMissed,
              ),
              const SizedBox(height: 30),
              _buildActionButtons(context, service),
              const SizedBox(height: 30),
              Text(
                'History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildHistoryList(service),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, FastingService service) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Log missed fast (e.g., for today)
              service.logMissedFast(DateTime.now());
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Missed Fast'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Log made up fast
              service.logMadeUpFast(DateTime.now());
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Made Up Fast'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(FastingService service) {
    final logs = service.logs;
    
    if (logs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No logs yet.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              log.isMissed ? Icons.close : Icons.check,
              color: log.isMissed ? AppColors.error : AppColors.success,
            ),
            title: Text(
              log.isMissed ? 'Missed Fast' : 'Made Up Fast',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(log.date.toString().split(' ')[0]), // Simple date format
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => service.deleteLog(log),
            ),
          ),
        );
      },
    );
  }
}
