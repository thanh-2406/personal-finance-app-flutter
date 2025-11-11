// =======================================================================
// screens/dashboard/income_report_view.dart
// (Statistics / "Thống kê" tab -> Thu nhập)
// =======================================================================

import 'package:flutter/material.dart';

class IncomeReportView extends StatelessWidget {
  const IncomeReportView({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen is identical in layout to the Expense view,
    // just with different data and labels.
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
                  Text('Thống kê thu nhập theo tháng', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  // Placeholder for Donut Chart
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green.shade100, width: 20),
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
                  Text('So sánh các loại thu nhập', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  // Dummy list
                  _buildCategoryItem(Icons.work, 'Lương', '20,000,000 đ', Colors.blue),
                  _buildCategoryItem(Icons.business_center, 'Freelance', '5,000,000 đ', Colors.cyan),
                  _buildCategoryItem(Icons.card_giftcard, 'Quà tặng', '500,000 đ', Colors.pink),
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
            Text('Tổng thu', style: Theme.of(context).textTheme.labelLarge),
            Text(
              '25,500,000 đ',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
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