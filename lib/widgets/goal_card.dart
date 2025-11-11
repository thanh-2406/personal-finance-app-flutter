import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/models/goal_model.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (goal.targetAmount > 0) 
        ? (goal.currentAmount / goal.targetAmount) 
        : 0.0;
    
    final percentage = (progress.clamp(0.0, 1.0) * 100).toStringAsFixed(0);
    final currencyFormat = (double amount) => '${amount.toStringAsFixed(0)} đ';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal Name
              Text(
                goal.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Progress Bar
              LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              const SizedBox(height: 8),

              // Progress Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${currencyFormat(goal.currentAmount)} / ${currencyFormat(goal.targetAmount)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}