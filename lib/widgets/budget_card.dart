// =======================================================================
// lib/widgets/budget_card.dart
// (UPDATED)
// =======================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app_flutter/models/budget_model.dart';
import 'package:personal_finance_app_flutter/models/budget_period.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart';
import 'package:personal_finance_app_flutter/utils/currency_formatter.dart'; 
import 'package:personal_finance_app_flutter/widgets/category_icon.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final List<TransactionModel> transactions;
  final VoidCallback onTap; 
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.transactions,
    required this.onTap, 
    required this.onEdit,
    required this.onDelete,
  });

  // --- NEW: Helper to format the period text ---
  String _getPeriodText() {
    final formatter = DateFormat('dd/MM');
    switch (budget.period) {
      case BudgetPeriod.daily:
        return 'Hôm nay (${formatter.format(budget.startDate.toDate())})';
      case BudgetPeriod.weekly:
        return 'Tuần này (${formatter.format(budget.startDate.toDate())} - ${formatter.format(budget.endDate!.toDate())})';
      case BudgetPeriod.monthly:
        return 'Tháng ${DateFormat('MM/yyyy').format(budget.startDate.toDate())}';
      case BudgetPeriod.custom:
         return '${formatter.format(budget.startDate.toDate())} - ${formatter.format(budget.endDate!.toDate())}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double spent = transactions
        .where((txn) => txn.type == 'expense')
        .fold(0.0, (sum, txn) => sum + txn.amount);

    final double progress = (budget.amount > 0) ? (spent / budget.amount) : 0.0;
    final int percentage = (progress * 100).toInt();

    String statusText;
    Color statusColor;

    if (percentage >= 100) {
      statusText = "Đã vượt ${percentage - 100}%";
      statusColor = Colors.red;
    } else if (percentage >= 85) { 
      statusText = "Sắp vượt $percentage%";
      statusColor = Colors.orange;
    } else {
      statusText = "Đã chi $percentage%";
      statusColor = Colors.green;
    }

    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12), 
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                child: CategoryIcon(category: budget.category),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.category,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    // --- NEW: Show period text ---
                    const SizedBox(height: 4),
                    Text(
                      _getPeriodText(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    // --- END OF NEW ---
                    const SizedBox(height: 8),
                    Text(
                      '${CurrencyFormatter.format(spent)} / ${CurrencyFormatter.format(budget.amount)}',
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                      color: statusColor,
                      backgroundColor: statusColor.withOpacity(0.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.red.shade700,
                    onPressed: onDelete,
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