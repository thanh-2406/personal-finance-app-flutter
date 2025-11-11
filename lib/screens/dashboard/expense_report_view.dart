// =======================================================================
// screens/dashboard/expense_report_view.dart
// (Statistics / "Thống kê" tab -> Chi tiêu)
// =======================================================================

import 'package:flutter/material.dart';

class ExpenseReportView extends StatelessWidget {
  const ExpenseReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Summary and Filters
          _buildSummaryAndFilters(context),
          const SizedBox(height: 16),

          // 2. Data Visualization Area (Donut Chart)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Thống kê chi tiêu theo tháng', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  // Placeholder for Donut Chart
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade100, width: 20),
                    ),
                    child: const Center(child: Text('Donut Chart\nPlaceholder', textAlign: TextAlign.center)),
                  ),
                ],
              ),
            ),
          ),

          // 3. Category Breakdown Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('So sánh các loại chi tiêu', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  // Dummy list
                  _buildCategoryItem(Icons.fastfood, 'Ăn uống', '5,000,000 đ', Colors.red),
                  _buildCategoryItem(Icons.shopping_cart, 'Mua sắm', '2,500,000 đ', Colors.orange),
                  _buildCategoryItem(Icons.movie, 'Giải trí', '1,000,000 đ', Colors.purple),
                  _buildCategoryItem(Icons.health_and_safety, 'Sức khoẻ', '500,000 đ', Colors.green),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryAndFilters(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Total
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tổng chi', style: Theme.of(context).textTheme.labelLarge),
            Text(
              '9,000,000 đ',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Filters
        Row(
          children: [
            // TODO: Implement with DropdownButton
            OutlinedButton(onPressed: () {}, child: const Text('Tháng 11')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () {}, child: const Text('2025')),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String name, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(name),
        trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}