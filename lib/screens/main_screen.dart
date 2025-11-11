import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/screens/dashboard/home_screen.dart';
import 'package:personal_finance_app_flutter/screens/dashboard/reports_screen.dart';
import 'package:personal_finance_app_flutter/screens/goals/saving_goals_list_screen.dart';
import 'package:personal_finance_app_flutter/screens/transactions/transaction_management_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // This list is now correct and has no conflicts.
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(), // Ví tiền (Wallet/Dashboard) // This is the correct HomeScreen
    const TransactionManagementScreen(), // Báo cáo (Reports/Transaction List)
    const SavingGoalsListScreen(), // Mục tiêu (Goals)
    const ReportsScreen(), // Thống kê (Statistics/Charts)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Ví tiền',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Báo cáo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Mục tiêu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Thống kê',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}