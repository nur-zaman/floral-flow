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
    final today = DateTime.now();
    final todayLogs = service.logs.where((log) {
      return log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day;
    }).toList();

    final hasMissedToday = todayLogs.any((log) => log.isMissed);
    final hasMadeUpToday = todayLogs.any((log) => log.isMadeUp);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context: context,
                label: 'Missed Fast',
                icon: Icons.add_circle_outline,
                color: AppColors.error,
                isLogged: hasMissedToday,
                onPressed: hasMissedToday
                    ? null
                    : () {
                        service.logMissedFast(DateTime.now());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Missed fast logged for today'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                context: context,
                label: 'Made Up Fast',
                icon: Icons.check_circle_outline,
                color: AppColors.success,
                isLogged: hasMadeUpToday,
                onPressed: hasMadeUpToday
                    ? null
                    : () {
                        service.logMadeUpFast(DateTime.now());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Made-up fast logged for today'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Tip: Use calendar to log fasts for other dates',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required bool isLogged,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLogged ? color.withOpacity(0.3) : Colors.transparent,
          width: 2,
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(isLogged ? Icons.check_circle : icon),
        label: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (isLogged)
              Text(
                'Logged',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLogged ? color.withOpacity(0.2) : color,
          foregroundColor: isLogged ? color : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isLogged ? 0 : 2,
        ),
      ),
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
