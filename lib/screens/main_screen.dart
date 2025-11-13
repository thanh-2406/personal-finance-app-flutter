import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/routes.dart';
import 'package:personal_finance_app_flutter/screens/budget/budget_screen.dart';
import 'package:personal_finance_app_flutter/screens/dashboard/home_screen.dart';
import 'package:personal_finance_app_flutter/screens/dashboard/reports_screen.dart';
import 'package:personal_finance_app_flutter/screens/goals/saving_goals_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const ReportsScreen(),
    const SavingGoalsListScreen(),
    const BudgetScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabPressed() {
    switch (_selectedIndex) {
      case 0: // Home
        Navigator.pushNamed(context, AppRoutes.categorySelect);
        break;
      case 1: // Statistics
        Navigator.pushNamed(context, AppRoutes.categorySelect);
        break;
      case 2: // Goals
        // --- THIS IS THE FIX ---
        // Navigate to the new AddEditGoalScreen (passing null for a new goal)
        Navigator.pushNamed(context, AppRoutes.addEditGoal);
        break;
      // --- END OF FIX ---
      case 3: // Budget
        Navigator.pushNamed(context, AppRoutes.addEditBudget);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        child: const Icon(Icons.add),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(icon: Icons.wallet, label: 'Ví tiền', index: 0),
            _buildNavItem(icon: Icons.pie_chart, label: 'Thống kê', index: 1),
            const SizedBox(width: 40), // The gap for the FAB
            _buildNavItem(icon: Icons.track_changes, label: 'Mục tiêu', index: 2),
            _buildNavItem(icon: Icons.account_balance, label: 'Ngân sách', index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;
    final color = isSelected ? Theme.of(context).colorScheme.primary : Colors.grey;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}