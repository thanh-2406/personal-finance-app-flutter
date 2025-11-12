import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:collection/collection.dart';
import 'package:personal_finance_app_flutter/widgets/category_icon.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Date Range Picker ---
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null &&
        picked != DateTimeRange(start: _startDate, end: _endDate)) {
      setState(() {
        _startDate = picked.start;
        // Add 1 day to end date to make it inclusive for queries
        _endDate = picked.end.add(const Duration(days: 1));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in.")));
    }
    final dbService = DatabaseService(userId: user.uid);

    final String dateRangeText =
        "${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate.subtract(const Duration(days: 1)))}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chi tiêu'),
            Tab(text: 'Thu nhập'),
          ],
        ),
      ),
      // We use a StreamBuilder that reacts to date changes
      body: StreamBuilder<List<TransactionModel>>(
        stream: dbService.getTransactionsByDateRange(_startDate, _endDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có dữ liệu cho khoảng thời gian này.'));
          }

          final allTransactions = snapshot.data!;

          // Filter transactions for each tab
          final expenses = allTransactions
              .where((txn) => txn.type == 'expense')
              .toList();
          final income =
              allTransactions.where((txn) => txn.type == 'income').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildReportView(context, 'Chi tiêu', expenses),
              _buildReportView(context, 'Thu nhập', income),
            ],
          );
        },
      ),
    );
  }

  // --- Reusable View for "Chi tiêu" and "Thu nhập" ---
  Widget _buildReportView(
      BuildContext context, String title, List<TransactionModel> transactions) {
    
    // --- 1. Calculate Totals and Group Data ---
    final double total = transactions.fold(0.0, (sum, txn) => sum + txn.amount);

    final Map<String, double> categoryMap =
        groupBy(transactions, (TransactionModel txn) => txn.category)
            .map((category, list) => MapEntry(
                  category,
                  list.fold(0.0, (sum, txn) => sum + txn.amount),
                ));

    // Sort by amount
    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // --- 2. Create Pie Chart Data ---
    final List<PieChartSectionData> pieSections =
        sortedCategories.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: CategoryIcon.getColor(entry.key), // Use consistent color
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Header (Total and Date Range) ---
          Text(
            'Tổng $title',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            '${total.toStringAsFixed(0)} đ',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: title == 'Chi tiêu' ? Colors.red : Colors.green),
          ),
          Text(
            "cho: ${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate.subtract(const Duration(days: 1)))}",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),

          // --- 2. Pie Chart ---
          SizedBox(
            height: 250,
            child: (pieSections.isEmpty)
                ? const Center(child: Text('Không có dữ liệu để vẽ biểu đồ.'))
                : PieChart(
                    PieChartData(
                      sections: pieSections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
          ),
          const SizedBox(height: 24),

          // --- 3. Category Breakdown List ---
          Text(
            'Phân loại $title',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          ...sortedCategories.map((entry) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    CategoryIcon.getColor(entry.key).withOpacity(0.1),
                child: CategoryIcon(
                  category: entry.key,
                  color: CategoryIcon.getColor(entry.key),
                ),
              ),
              title: Text(entry.key),
              trailing: Text(
                '${entry.value.toStringAsFixed(0)} đ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }),
        ],
      ),
    );
  }
}