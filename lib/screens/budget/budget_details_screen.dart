// =======================================================================
// lib/screens/budget/budget_details_screen.dart
// (UPDATED)
// =======================================================================

import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/models/budget_model.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart';
import 'package:personal_finance_app_flutter/utils/currency_formatter.dart';
import 'package:personal_finance_app_flutter/widgets/category_icon.dart';
import 'package:intl/intl.dart';

class BudgetDetailsScreen extends StatelessWidget {
  final Budget budget;
  final List<TransactionModel> transactions; // These are pre-filtered by budget_screen

  const BudgetDetailsScreen({
    super.key,
    required this.budget,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    // This list is already filtered, so we just sum them up
    final double spent = transactions
        .where((txn) => txn.type == 'expense')
        .fold(0.0, (sum, txn) => sum + txn.amount);
    
    final double remaining = budget.amount - spent;
    final double progress = (budget.amount > 0) ? (spent / budget.amount) : 0.0;
    final int percentage = (progress * 100).toInt();

    Color progressColor = Colors.green;
    if (percentage >= 100) {
      progressColor = Colors.red;
    } else if (percentage >= 85) {
      progressColor = Colors.orange;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết: ${budget.category}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          child: CategoryIcon(category: budget.category),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          budget.category,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${CurrencyFormatter.format(spent)} / ${CurrencyFormatter.format(budget.amount)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                      color: progressColor,
                      backgroundColor: progressColor.withOpacity(0.2),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      'Phần trăm đã sử dụng:',
                      '$percentage%',
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      context,
                      'Số tiền đã chi:',
                      CurrencyFormatter.format(spent),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      context,
      
                      'Số tiền còn lại:',
                      CurrencyFormatter.format(remaining),
                      color: remaining < 0 ? Colors.red : Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 2. Transaction List
            Text(
              'Các giao dịch trong kỳ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            if (transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('Không có giao dịch nào.')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final txn = transactions[index];
                  // All transactions here are expenses
                  return ListTile(
                    leading: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                    title: Text(txn.notes.isNotEmpty ? txn.notes : txn.category),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(txn.date.toDate())),
                    trailing: Text(
                      '-${CurrencyFormatter.format(txn.amount)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyLarge),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}