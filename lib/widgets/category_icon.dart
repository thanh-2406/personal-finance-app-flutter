import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String category;
  final Color? color;

  const CategoryIcon({super.key, required this.category, this.color});

  static IconData getIcon(String category) {
    switch (category) {
      case 'Food':
      case 'Ăn uống': // <--- ADDED
        return Icons.fastfood_outlined;
      case 'Travel':
      case 'Du lịch': // <--- ADDED
        return Icons.flight_takeoff_outlined;
      case 'Health':
      case 'Sức khỏe': // <--- ADDED
        return Icons.medical_services_outlined;
      case 'Transport':
      case 'Di chuyển': // <--- ADDED
        return Icons.directions_bus_outlined;
      case 'Shopping':
      case 'Mua sắm': // <--- ADDED
        return Icons.shopping_cart_outlined;
      case 'Entertainment':
      case 'Giải trí': // <--- ADDED
        return Icons.movie_outlined;
      case 'Bills':
      case 'Hóa đơn': // <--- ADDED
        return Icons.receipt_long_outlined;
      case 'Salary':
      case 'Lương': // <--- ADDED
        return Icons.work_outline;
      case 'Freelance':
      case 'Làm thêm': // <--- ADDED
        return Icons.computer_outlined;
      case 'Gift':
      case 'Quà tặng': // <--- ADDED
        return Icons.card_giftcard_outlined;
      case 'Goal':
        return Icons.savings_outlined;
      case 'Other':
      case 'Khác': // <--- ADDED
      default:
        if (category.startsWith('Mục tiêu:')) {
          return Icons.savings_outlined;
        }
        return Icons.more_horiz_outlined;
    }
  }

  static Color getColor(String category) {
    switch (category) {
      case 'Food':
      case 'Ăn uống': // <--- ADDED
        return Colors.red;
      case 'Travel':
      case 'Du lịch': // <--- ADDED
        return Colors.blue;
      case 'Health':
      case 'Sức khỏe': // <--- ADDED
        return Colors.green;
      case 'Transport':
      case 'Di chuyển': // <--- ADDED
        return Colors.orange;
      case 'Shopping':
      case 'Mua sắm': // <--- ADDED
        return Colors.purple;
      case 'Entertainment':
      case 'Giải trí': // <--- ADDED
        return Colors.teal;
      case 'Bills':
      case 'Hóa đơn': // <--- ADDED
        return Colors.cyan;
      case 'Salary':
      case 'Lương': // <--- ADDED
        return Colors.lightGreen;
      case 'Freelance':
      case 'Làm thêm': // <--- ADDED
        return Colors.indigo;
      case 'Gift':
      case 'Quà tặng': // <--- ADDED
        return Colors.pink;
      case 'Goal':
        return Colors.amber;
      case 'Other':
      case 'Khác': // <--- ADDED
      default:
        if (category.startsWith('Mục tiêu:')) {
          return Colors.amber;
        }
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      getIcon(category),
      color: color ?? getColor(category),
    );
  }
}