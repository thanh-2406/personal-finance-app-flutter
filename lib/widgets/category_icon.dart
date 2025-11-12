import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String category;
  final Color? color;

  const CategoryIcon({super.key, required this.category, this.color});

  // Helper function to get an icon for a category
  static IconData getIcon(String category) {
    switch (category) {
      case 'Ăn uống':
        return Icons.fastfood_outlined;
      case 'Du lịch':
        return Icons.flight_takeoff_outlined;
      case 'Chữa bệnh':
        return Icons.medical_services_outlined;
      case 'Di chuyển':
        return Icons.directions_bus_outlined;
      case 'Mua sắm':
        return Icons.shopping_cart_outlined;
      case 'Giải trí':
        return Icons.movie_outlined;
      case 'Hoá đơn':
        return Icons.receipt_long_outlined;
      case 'Lương':
        return Icons.work_outline;
      case 'Freelance':
        return Icons.computer_outlined;
      case 'Quà tặng':
        return Icons.card_giftcard_outlined;
      case 'Khác':
      default:
        return Icons.more_horiz_outlined;
    }
  }

  // Helper function to get a consistent color for a category
  static Color getColor(String category) {
    switch (category) {
      case 'Ăn uống':
        return Colors.red;
      case 'Du lịch':
        return Colors.blue;
      case 'Chữa bệnh':
        return Colors.green;
      case 'Di chuyển':
        return Colors.orange;
      case 'Mua sắm':
        return Colors.purple;
      case 'Giải trí':
        return Colors.teal;
      case 'Hoá đơn':
        return Colors.cyan;
      case 'Lương':
        return Colors.lightGreen;
      case 'Freelance':
        return Colors.indigo;
      case 'Quà tặng':
        return Colors.pink;
      case 'Khác':
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      getIcon(category),
      color: color, // Use provided color, or default from Theme
    );
  }
}