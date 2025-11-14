import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart';
import 'package:personal_finance_app_flutter/routes.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:personal_finance_app_flutter/utils/currency_formatter.dart'; // Import formatter
import 'package:personal_finance_app_flutter/widgets/category_icon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.login, (route) => false);
      return const Scaffold();
    }
    
    final dbService = DatabaseService(userId: user.uid);
    final userName = user.displayName ?? user.email?.split('@').first ?? "User";

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
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
                    "Hello, $userName",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // --- FIX: Removed the empty actions button ---
            ),
            
            SliverToBoxAdapter(
              child: _buildAccountSummaryCard(context, dbService),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: _SectionHeaderDelegate('Lịch sử giao dịch'),
            ),
            _buildTransactionList(dbService),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSummaryCard(BuildContext context, DatabaseService dbService) {
    return StreamBuilder<List<TransactionModel>>(
      stream: dbService.getTransactionsStream(),
      builder: (context, snapshot) {
        double totalIncome = 0.0;
        double totalExpense = 0.0;

        if (snapshot.hasData) {
          for (var txn in snapshot.data!) {
            if (txn.type == 'income') {
              totalIncome += txn.amount;
            } else {
              totalExpense += txn.amount;
            }
          }
        }
        
        final double balance = totalIncome - totalExpense;
        final double total = totalIncome + totalExpense;
        final double incomeProgress = total > 0 ? totalIncome / total : 0;
        final double expenseProgress = total > 0 ? totalExpense / total : 0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Số dư hiện tại',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(balance), // <-- USE FORMATTER
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildBalanceBar(
                  context: context,
                  label: 'Thu nhập',
                  amount: CurrencyFormatter.format(totalIncome), // <-- USE FORMATTER
                  progress: incomeProgress,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildBalanceBar(
                  context: context,
                  label: 'Chi tiêu',
                  amount: CurrencyFormatter.format(totalExpense), // <-- USE FORMATTER
                  progress: expenseProgress,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceBar({
    required BuildContext context,
    required String label,
    required String amount,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            Text(amount, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withAlpha(51), 
          color: color,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  Widget _buildTransactionList(DatabaseService dbService) {
    final DateFormat dayFormatter = DateFormat('dd-MM-yyyy');
    final DateFormat displayFormatter = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN');

    return StreamBuilder<List<TransactionModel>>(
      stream: dbService.getTransactionsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter( 
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text('Chưa có giao dịch nào.'),
              ),
            ),
          );
        }

        final transactions = snapshot.data!;
        
        final groupedTransactions = groupBy(
          transactions,
          (TransactionModel txn) => dayFormatter.format(txn.date.toDate()),
        );

        final dates = groupedTransactions.keys.toList();

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final dateKey = dates[index];
              final items = groupedTransactions[dateKey]!;
              final displayDate = displayFormatter.format(items.first.date.toDate());

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      displayDate,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
                    ),
                  ),
                  ...items.map((txn) => ListTile(
                        leading: CircleAvatar(
                          // --- This will now use the fixed CategoryIcon ---
                          child: CategoryIcon(category: txn.category),
                        ),
                        title: Text(txn.category),
                        subtitle: Text(txn.notes),
                        trailing: Text(
                          '${txn.type == 'income' ? '+' : '-'}${CurrencyFormatter.format(txn.amount)}', // <-- USE FORMATTER
                          style: TextStyle(
                            color: txn.type == 'income' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                ],
              );
            },
            childCount: dates.length,
          ),
        );
      },
    );
  }
}

class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  _SectionHeaderDelegate(this.title);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, 
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  double get maxExtent => 48;
  @override
  double get minExtent => 48;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}