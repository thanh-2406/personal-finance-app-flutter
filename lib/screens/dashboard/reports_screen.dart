// =======================================================================
// screens/dashboard/reports_screen.dart
// (Statistics / "Thống kê" tab) - Hosts the TabBar
// =======================================================================

import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/screens/dashboard/expense_report_view.dart';
import 'package:personal_finance_app_flutter/screens/dashboard/income_report_view.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thống kê'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chi tiêu'),
              Tab(text: 'Thu nhập'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ExpenseReportView(),
            IncomeReportView(),
          ],
        ),
      ),
    );
  }
}