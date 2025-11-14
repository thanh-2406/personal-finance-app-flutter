import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app_flutter/models/budget_model.dart';
import 'package:personal_finance_app_flutter/routes.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:personal_finance_app_flutter/services/notification_service.dart';
import 'package:personal_finance_app_flutter/utils/currency_formatter.dart'; // Import formatter
import 'package:personal_finance_app_flutter/widgets/budget_card.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final String _selectedMonthYear = DateFormat('MM-yyyy').format(DateTime.now());
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
      
      // Listen to notification settings
      _dbService.getUserNotificationSettingsStream().listen((isEnabled) {
        if (mounted) {
          setState(() {
            _notificationsEnabled = isEnabled;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in.")));
    }

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: _dbService.getTransactionsByDateRange(
            DateTime(DateTime.now().year, DateTime.now().month, 1),
            DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
          ),
          builder: (context, transactionSnapshot) {
            final allTransactions = transactionSnapshot.data ?? [];

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

                StreamBuilder<List<Budget>>(
                  stream: _dbService.getBudgetsStream(_selectedMonthYear),
                  builder: (context, budgetSnapshot) {
                    List<Budget> budgets = budgetSnapshot.data ?? [];

                    // --- FIX: Only check notifications if enabled ---
                    if (_notificationsEnabled &&
                        budgetSnapshot.connectionState ==
                            ConnectionState.active &&
                        transactionSnapshot.connectionState ==
                            ConnectionState.active) {
                      _notificationService.checkBudgets(
                          budgets, allTransactions);
                    }
                    // --- END OF FIX ---

                    double totalBudget = budgets.fold(
                        0.0, (sum, budget) => sum + budget.amount);
                    double totalSpent = allTransactions
                        .where((txn) => txn.type == 'expense')
                        .fold(0.0, (sum, txn) => sum + txn.amount);
                    double remaining = totalBudget - totalSpent;
                    double progress =
                        (totalBudget > 0) ? (totalSpent / totalBudget) : 0;

                    return SliverToBoxAdapter(
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
                                    "Tổng ngân sách tháng",
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    DateFormat('MMMM yyyy', 'vi_VN')
                                        .format(DateTime.now()),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                CurrencyFormatter.format(totalBudget), // <-- USE FORMATTER
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
                    );
                  },
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
                        // --- FIX: Functional Switch ---
                        Switch(
                          value: _notificationsEnabled, 
                          onChanged: (val) {
                            _dbService.updateUserNotificationSettings(val);
                            // setState is handled by the stream listener
                          },
                        ),
                        // --- END OF FIX ---
                      ],
                    ),
                  ),
                ),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SectionHeaderDelegate('Danh mục chi tiêu'),
                ),
                StreamBuilder<List<Budget>>(
                  stream: _dbService.getBudgetsStream(_selectedMonthYear),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: const Center(
                            child: Text(
                                "Bạn chưa có ngân sách nào cho tháng này."),
                          ),
                        ),
                      );
                    }
                    final budgets = snapshot.data!;

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final budget = budgets[index];
                          final categoryTransactions = allTransactions
                              .where((txn) => txn.category == budget.category)
                              .toList();

                          return BudgetCard(
                            budget: budget,
                            transactions: categoryTransactions,
                            // --- FIX: Add onTap for details ---
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.budgetDetails,
                                arguments: {
                                  'budget': budget,
                                  'transactions': categoryTransactions,
                                },
                              );
                            },
                            // --- END OF FIX ---
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
                        childCount: budgets.length,
                      ),
                    );
                  },
                ),
              ],
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