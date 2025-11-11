// =======================================================================
// screens/budget/budget_history_screen.dart
// =======================================================================

import 'package:flutter/material.dart';

class BudgetReminderHistoryScreen extends StatelessWidget {
  const BudgetReminderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final history = [
      {'level': 'warning', 'category': 'Ăn uống', 'message': 'Đã đạt 90% ngân sách', 'date': '10/11/2025'},
      {'level': 'exceeded', 'category': 'Mua sắm', 'message': 'Đã vượt 100% ngân sách', 'date': '08/11/2025'},
      {'level': 'warning', 'category': 'Giải trí', 'message': 'Đã đạt 90% ngân sách', 'date': '05/11/2025'},
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử nhắc nhở'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          final bool isWarning = item['level'] == 'warning';
          
          return ListTile(
            leading: Icon(
              isWarning ? Icons.warning_amber : Icons.error_outline,
              color: isWarning ? Colors.orange : Colors.red,
            ),
            title: Text(item['category'] as String),
            subtitle: Text(item['message'] as String),
            trailing: Text(item['date'] as String),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextButton.icon(
          onPressed: () {
            // TODO: Clear history
          },
          icon: const Icon(Icons.delete_sweep, color: Colors.grey),
          label: const Text('Xoá lịch sử', style: TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }
}