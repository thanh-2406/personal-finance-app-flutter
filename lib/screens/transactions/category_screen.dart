import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/routes.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseCategories = [
      {'name': 'Ăn uống', 'icon': Icons.fastfood}, // <--- UPDATED
      {'name': 'Sức khỏe', 'icon': Icons.health_and_safety}, // <--- UPDATED
      {'name': 'Du lịch', 'icon': Icons.flight}, // <--- UPDATED
      {'name': 'Mua sắm', 'icon': Icons.shopping_cart}, // <--- UPDATED
      {'name': 'Di chuyển', 'icon': Icons.directions_bus}, // <--- UPDATED
      {'name': 'Hóa đơn', 'icon': Icons.receipt}, // <--- UPDATED
      {'name': 'Giải trí', 'icon': Icons.movie}, // <--- UPDATED
      {'name': 'Khác', 'icon': Icons.more_horiz}, // <--- UPDATED
    ];
    
    final incomeCategories = [
      {'name': 'Lương', 'icon': Icons.work}, // <--- UPDATED
      {'name': 'Làm thêm', 'icon': Icons.business_center}, // <--- UPDATED
      {'name': 'Quà tặng', 'icon': Icons.card_giftcard}, // <--- UPDATED
      {'name': 'Khác', 'icon': Icons.more_horiz}, // <--- UPDATED
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
                Text(category['name'] as String, textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }
}