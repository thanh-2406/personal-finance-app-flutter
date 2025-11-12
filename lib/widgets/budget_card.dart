import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/models/budget_model.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart';
import 'package:personal_finance_app_flutter/widgets/category_icon.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final List<TransactionModel> transactions;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate spending for this budget's category
    final double spent = transactions
        .where((txn) => txn.type == 'expense')
        .fold(0.0, (sum, txn) => sum + txn.amount);

    final double progress = (budget.amount > 0) ? (spent / budget.amount) : 0.0;
    final double remaining = budget.amount - spent;
    final int percentage = (progress * 100).toInt();

    String statusText;
    Color statusColor;

    if (percentage >= 100) {
      statusText = "Đã vượt ${percentage - 100}%";
      statusColor = Colors.red;
    } else if (percentage >= 90) {
      statusText = "Sắp vượt $percentage%";
      statusColor = Colors.orange;
    } else {
      statusText = "Còn lại ${100 - percentage}%";
      statusColor = Colors.green;
    }

    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Icon
            CircleAvatar(
              child: CategoryIcon(category: budget.category),
            ),
            const SizedBox(width: 12),
            // Middle section (Info)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    budget.category,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${spent.toStringAsFixed(0)} đ / ${budget.amount.toStringAsFixed(0)} đ',
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
            // Right side (Actions)
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
    );
  }
}