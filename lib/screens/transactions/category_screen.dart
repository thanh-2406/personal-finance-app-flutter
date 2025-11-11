import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/routes.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This category data can remain static or be moved to Firestore later
    final expenseCategories = [
      {'name': 'Food', 'icon': Icons.fastfood},
      {'name': 'Health', 'icon': Icons.health_and_safety},
      {'name': 'Travel', 'icon': Icons.flight},
      {'name': 'Shopping', 'icon': Icons.shopping_cart},
      {'name': 'Bills', 'icon': Icons.receipt},
      {'name': 'Other', 'icon': Icons.more_horiz},
    ];
    
    final incomeCategories = [
      {'name': 'Salary', 'icon': Icons.work},
      {'name': 'Freelance', 'icon': Icons.business_center},
      {'name': 'Gift', 'icon': Icons.card_giftcard},
      {'name': 'Other', 'icon': Icons.more_horiz},
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chọn danh mục'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chi tiêu'),
              Tab(text: 'Thu nhập'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCategoryGrid(context, expenseCategories, 'expense'),
            _buildCategoryGrid(context, incomeCategories, 'income'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<Map<String, dynamic>> categories, String type) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return InkWell(
          onTap: () {
            // Navigate to New Transaction screen, passing the category and type
            Navigator.pushNamed(
              context, 
              AppRoutes.newTransaction,
              arguments: {
                'category': category['name'] as String,
                'type': type,
              }
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Card(
            elevation: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(category['icon'] as IconData, size: 40, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                Text(category['name'] as String),
              ],
            ),
          ),
        );
      },
    );
  }
}