import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String category;
  final Color? color;

  const CategoryIcon({super.key, required this.category, this.color});

  // Helper function to get an icon for a category
  static IconData getIcon(String category) {
    switch (category) {
      // --- FIX: Changed to English keys ---
      case 'Food':
        return Icons.fastfood_outlined;
      case 'Travel':
        return Icons.flight_takeoff_outlined;
      case 'Health':
        return Icons.medical_services_outlined;
      case 'Transport': // Assuming 'Di chuyển' maps to 'Transport' or similar
        return Icons.directions_bus_outlined;
      case 'Shopping':
        return Icons.shopping_cart_outlined;
      case 'Entertainment': // Assuming 'Giải trí'
        return Icons.movie_outlined;
      case 'Bills':
        return Icons.receipt_long_outlined;
      case 'Salary':
        return Icons.work_outline;
      case 'Freelance':
        return Icons.computer_outlined;
      case 'Gift':
        return Icons.card_giftcard_outlined;
      // --- FIX: Added specific goal category ---
      case 'Goal': // For goal-related transactions
        return Icons.savings_outlined;
      case 'Other':
      default:
        // Handle 'Mục tiêu: ...' category
        if (category.startsWith('Mục tiêu:')) {
          return Icons.savings_outlined;
        }
        return Icons.more_horiz_outlined;
    }
  }

  // Helper function to get a consistent color for a category
  static Color getColor(String category) {
    switch (category) {
      // --- FIX: Changed to English keys ---
      case 'Food':
        return Colors.red;
      case 'Travel':
        return Colors.blue;
      case 'Health':
        return Colors.green;
      case 'Transport':
        return Colors.orange;
      case 'Shopping':
        return Colors.purple;
      case 'Entertainment':
        return Colors.teal;
      case 'Bills':
        return Colors.cyan;
      case 'Salary':
        return Colors.lightGreen;
      case 'Freelance':
        return Colors.indigo;
      case 'Gift':
        return Colors.pink;
      // --- FIX: Added specific goal category ---
      case 'Goal':
        return Colors.amber;
      case 'Other':
      default:
        // Handle 'Mục tiêu: ...' category
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
      color: color ?? getColor(category), // Use specific color OR default category color
    );
  }
}