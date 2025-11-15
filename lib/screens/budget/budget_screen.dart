// =======================================================================
// lib/screens/budget/budget_screen.dart
// (UPDATED)
// =======================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app_flutter/models/budget_model.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart';
import 'package:personal_finance_app_flutter/routes.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:personal_finance_app_flutter/services/notification_service.dart';
import 'package:personal_finance_app_flutter/utils/currency_formatter.dart'; 
import 'package:personal_finance_app_flutter/widgets/budget_card.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // --- REMOVED: _selectedMonthYear ---
  late DatabaseService _dbService;
  late NotificationService _notificationService;
  String _userName = "User";
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    if (user != null) {
      _dbService = DatabaseService(userId: user.uid);
      _notificationService = NotificationService(dbService: _dbService);
      _userName = user.displayName ?? user.email?.split('@').first ?? "User";
      
      _dbService.getUserNotificationSettingsStream().listen((isEnabled) {
        if (mounted) {
          setState(() {
            _notificationsEnabled = isEnabled;
          });
        }
      });
    }
  }
  
  // --- NEW: Helper to filter only budgets active today ---
  List<Budget> _filterActiveBudgets(List<Budget> allBudgets) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return allBudgets.where((budget) {
      final startDate = budget.startDate.toDate();
      // For non-custom periods, endDate is null.
      final endDate = budget.endDate?.toDate() ?? DateTime(startDate.year, startDate.month, startDate.day, 23, 59, 59);

      // Ensure endDate includes the whole day
      final inclusiveEndDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      // Check if today is within the budget's start and end date
      return (today.isAfter(startDate) || today.isAtSameMomentAs(startDate)) &&
             (today.isBefore(inclusiveEndDate) || today.isAtSameMomentAs(inclusiveEndDate));
    }).toList();
  }

  // --- NEW: Helper to get start/end dates for transaction query ---
  (DateTime, DateTime) _getTransactionDateRangeForBudgets(List<Budget> activeBudgets) {
    if (activeBudgets.isEmpty) {
      final now = DateTime.now();
      return (DateTime(now.year, now.month, now.day), DateTime(now.year, now.month, now.day, 23, 59, 59));
    }

    // Find the earliest start date and latest end date from all active budgets
    DateTime minStart = activeBudgets.first.startDate.toDate();
    DateTime maxEnd = activeBudgets.first.endDate?.toDate() ?? minStart;

    for (var budget in activeBudgets) {
      if (budget.startDate.toDate().isBefore(minStart)) {
        minStart = budget.startDate.toDate();
      }
      final budgetEnd = budget.endDate?.toDate() ?? budget.startDate.toDate();
      if (budgetEnd.isAfter(maxEnd)) {
        maxEnd = budgetEnd;
      }
    }
    return (minStart, maxEnd);
  }


  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in.")));
    }

    return Scaffold(
      body: SafeArea(
        // --- UPDATED: StreamBuilder for ALL budgets ---
        child: StreamBuilder<List<Budget>>(
          stream: _dbService.getBudgetsStream(),
          builder: (context, budgetSnapshot) {

            // Filter all budgets to get only active ones
            final allBudgets = budgetSnapshot.data ?? [];
            final activeBudgets = _filterActiveBudgets(allBudgets);

            // Get the transaction date range based on active budgets
            final (minDate, maxDate) = _getTransactionDateRangeForBudgets(activeBudgets);
            
            // --- NEW: StreamBuilder for transactions based on the active budget range ---
            return StreamBuilder<List<TransactionModel>>(
              stream: _dbService.getTransactionsByDateRange(minDate, maxDate),
              builder: (context, transactionSnapshot) {
                
                final allTransactions = transactionSnapshot.data ?? [];

                // Check notifications
                if (_notificationsEnabled &&
                    budgetSnapshot.connectionState == ConnectionState.active &&
                    transactionSnapshot.connectionState == ConnectionState.active) {
                  _notificationService.checkBudgets(
                      activeBudgets, allTransactions);
                }

                // Calculate totals based on ACTIVE budgets
                double totalBudget = activeBudgets.fold(
                    0.0, (sum, budget) => sum + budget.amount);
                
                // Calculate total spending for *only* the categories in the active budgets
                double totalSpent = 0.0;
                for (var budget in activeBudgets) {
                   final categorySpent = allTransactions
                      .where((txn) => txn.type == 'expense' && txn.category == budget.category)
                      .fold(0.0, (sum, txn) => sum + txn.amount);
                  totalSpent += categorySpent;
                }
                
                double remaining = totalBudget - totalSpent;
                double progress = (totalBudget > 0) ? (totalSpent / totalBudget) : 0;

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      elevation: 0,
                      titleSpacing: 0,
                      title: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.profile);
                            },
                            child: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Hi, $_userName",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          tooltip: 'Thông báo',
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.notifications);
                          },
                        ),
                      ],
                    ),

                    SliverToBoxAdapter(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Tổng ngân sách ",
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy', 'vi_VN')
                                        .format(DateTime.now()),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                CurrencyFormatter.format(totalBudget), 
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: progress,
                                minHeight: 10,
                                borderRadius: BorderRadius.circular(5),
                                color: (progress > 1) ? Colors.red : (progress > 0.85) ? Colors.orange : Colors.green,
                                backgroundColor: (progress > 1) ? Colors.red.withAlpha(51) : (progress > 0.85) ? Colors.orange.withAlpha(51) : Colors.green.withAlpha(51),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                (remaining < 0)
                                    ? "Đã vượt ${CurrencyFormatter.format(remaining.abs())}"
                                    : "Còn lại ${CurrencyFormatter.format(remaining)}",
                                style: TextStyle(
                                  color: (remaining < 0) ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Thông báo tự động",
                                style: TextStyle(fontSize: 16)),
                            Switch(
                              value: _notificationsEnabled, 
                              onChanged: (val) {
                                _dbService.updateUserNotificationSettings(val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SectionHeaderDelegate('Ngân sách đang hoạt động'),
                    ),
                    
                    // --- UPDATED: Show ACTIVE budgets ---
                    if (budgetSnapshot.connectionState == ConnectionState.waiting ||
                        transactionSnapshot.connectionState == ConnectionState.waiting)
                      const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()))
                    else if (activeBudgets.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: const Center(
                            child: Text(
                                "Bạn chưa có ngân sách nào hoạt động cho hôm nay."),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final budget = activeBudgets[index];
                            // Filter transactions for *this* budget only
                            final categoryTransactions = allTransactions
                                .where((txn) => txn.category == budget.category)
                                .toList();

                            return BudgetCard(
                              budget: budget,
                              transactions: categoryTransactions,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.budgetDetails,
                                  arguments: {
                                    'budget': budget,
                                    // Pass only relevant transactions
                                    'transactions': categoryTransactions,
                                  },
                                );
                              },
                              onEdit: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.addEditBudget,
                                    arguments: budget);
                              },
                              onDelete: () {
                                _dbService.deleteBudget(budget.id!);
                              },
                            );
                          },
                          childCount: activeBudgets.length,
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  _SectionHeaderDelegate(this.title);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  double get maxExtent => 48;
  @override
  double get minExtent => 48;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}