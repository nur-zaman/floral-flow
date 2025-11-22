import 'package:flutter/material.dart';
import '../theme/colors.dart';

class FlowerProgressWidget extends StatelessWidget {
  final int completed;
  final int total;

  const FlowerProgressWidget({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 1.0 : completed / total;
    
    return Column(
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight.withOpacity(0.3),
                ),
              ),
              // The Flower (Simplified representation for now)
              Icon(
                Icons.local_florist,
                size: 100 + (50 * progress), // Grows with progress
                color: Color.lerp(AppColors.secondary, AppColors.primary, progress),
              ),
              if (progress >= 1.0)
                const Positioned(
                  bottom: 20,
                  child: Icon(Icons.star, color: Colors.amber, size: 30),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '$completed / $total Fasting Days Made Up',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.surface,
          color: AppColors.primary,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }
}
