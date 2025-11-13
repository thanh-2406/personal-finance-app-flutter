import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/models/goal_model.dart';
import 'package:personal_finance_app_flutter/utils/currency_formatter.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback onEdit; // NEW: Edit button callback

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (goal.targetAmount > 0)
        ? (goal.currentAmount / goal.targetAmount)
        : 0.0;
    final String percentage = (progress * 100).toStringAsFixed(0);
    final bool isCompleted = progress >= 1.0;

    return Card(
      // --- NEW: Change color if completed ---
      color: isCompleted ? Colors.green.shade50 : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal Name, Important Star, and Edit Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // --- NEW: Show star if important ---
                        if (goal.isImportant)
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                        if (goal.isImportant) const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            goal.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // --- NEW: Edit Button ---
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: onEdit,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- NEW: Show "Completed" text or Progress Bar ---
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'ĐÃ HOÀN THÀNH MỤC TIÊU!',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // --- USE CURRENCY FORMATTER ---
                        Text(
                          '${CurrencyFormatter.format(goal.currentAmount)} / ${CurrencyFormatter.format(goal.targetAmount)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '$percentage%',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
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