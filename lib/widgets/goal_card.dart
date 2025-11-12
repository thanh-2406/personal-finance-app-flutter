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
    // --- THIS IS THE BUG FIX ---
    // Ensure targetAmount is not zero to avoid division by zero
    final double progress = (goal.targetAmount > 0)
        ? (goal.currentAmount / goal.targetAmount)
        : 0.0;
    // Format the percentage
    final String percentage = (progress * 100).toStringAsFixed(0);
    // --- END OF BUG FIX ---

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
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Progress Bar
              LinearProgressIndicator(
                value: progress, // Use the calculated progress
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                    '$percentage%', // Use the calculated percentage
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