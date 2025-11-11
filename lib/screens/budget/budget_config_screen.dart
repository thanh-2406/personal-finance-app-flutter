// =======================================================================
// screens/budget/budget_config_screen.dart
// =======================================================================

import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/routes.dart';
import 'package:personal_finance_app_flutter/widgets/primary_button.dart';

class BudgetConfigurationScreen extends StatelessWidget {
  const BudgetConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final budgets = [
      {'name': 'Ăn uống', 'spent': 4500000, 'limit': 5000000},
      {'name': 'Mua sắm', 'spent': 2000000, 'limit': 2000000},
      {'name': 'Giải trí', 'spent': 500000, 'limit': 1500000},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt ngân sách'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Lịch sử nhắc nhở',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.budgetHistory);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Notification Toggle
            SwitchListTile(
              title: const Text('Nhắc nhở hàng tháng'),
              value: true, // Dummy
              onChanged: (bool value) {
                // TODO: Save preference
              },
              secondary: const Icon(Icons.notifications_active),
            ),
            const Divider(height: 32),
            
            // 2. Category List
            Text('Ngân sách theo danh mục', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...budgets.map((budget) => _buildBudgetCard(context, budget)),

            // 3. Add Budget Button
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Show "Add Budget" dialog
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm giới hạn ngân sách'),
            ),
            
            // 4. Save Button
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Lưu',
              onPressed: () {
                // TODO: Save all settings
                
                // Example of showing the alert popup
                _showBudgetAlert(
                  context,
                  title: '⚠️ Sắp vượt ngân sách!',
                  category: 'Ăn uống',
                  spent: 4500000,
                  limit: 5000000,
                  color: Colors.orange,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, Map<String, dynamic> budget) {
    final double spent = budget['spent'].toDouble();
    final double limit = budget['limit'].toDouble();
    final double progress = (limit > 0) ? (spent / limit) : 0;
    
    Color progressColor = Colors.green;
    if (progress > 0.9) progressColor = Colors.orange;
    if (progress >= 1.0) progressColor = Colors.red;

    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(budget['name'], style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    // TODO: Edit this budget
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${spent.toStringAsFixed(0)} đ / ${limit.toStringAsFixed(0)} đ'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
              color: progressColor,
              backgroundColor: progressColor.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  // 2.2 Budget Alert Notification (as a dialog)
  void _showBudgetAlert(
    BuildContext context, {
    required String title,
    required String category,
    required double spent,
    required double limit,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final percentage = (spent / limit * 100).toStringAsFixed(0);
        return AlertDialog(
          title: Text(title, style: TextStyle(color: color)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Visual Indicator (placeholder)
              SizedBox(
                height: 100,
                width: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: spent / limit,
                      strokeWidth: 10,
                      color: color,
                      backgroundColor: color.withOpacity(0.2),
                    ),
                    Center(child: Text('$percentage%', style: Theme.of(context).textTheme.headlineSmall)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Danh mục: $category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Đã chi: ${spent.toStringAsFixed(0)} đ / ${limit.toStringAsFixed(0)} đ'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Bỏ qua'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to budget details
                Navigator.of(context).pop();
              },
              child: const Text('Xem chi tiết'),
            ),
          ],
        );
      },
    );
  }
}