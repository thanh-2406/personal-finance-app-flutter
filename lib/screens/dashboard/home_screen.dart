import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart';
import 'package:personal_finance_app_flutter/routes.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) {
      // This should not happen if AuthWrapper is working, but it's good practice.
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      return const Scaffold();
    }
    
    final dbService = DatabaseService(userId: user.uid);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. Header
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.grey[50],
              elevation: 0,
              title: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sign Out',
                  onPressed: () async {
                    await AuthService().signOut();
                    // AuthWrapper will handle navigation
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.editProfile);
                  },
                ),
              ],
            ),
            
            // 2. Account Summary Card (StreamBuilder for real-time totals)
            SliverToBoxAdapter(
              child: _buildAccountSummaryCard(context, dbService),
            ),

            // 3. Transaction History List
            SliverPersistentHeader(
              pinned: true,
              delegate: _SectionHeaderDelegate('Lịch sử giao dịch'),
            ),
            _buildTransactionList(dbService),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.categorySelect);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget for the summary card
  Widget _buildAccountSummaryCard(BuildContext context, DatabaseService dbService) {
    // This StreamBuilder listens to all transactions to calculate totals
    return StreamBuilder<List<TransactionModel>>(
      stream: dbService.getTransactionsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(child: Center(child: CircularProgressIndicator()));
        }

        double totalIncome = 0;
        double totalExpense = 0;
        for (var txn in snapshot.data!) {
          if (txn.type == TransactionType.income) {
            totalIncome += txn.amount;
          } else {
            totalExpense += txn.amount;
          }
        }
        double currentBalance = totalIncome - totalExpense;
        double totalBudget = totalIncome; // Or some other metric
        double incomeProgress = totalBudget > 0 ? (totalIncome / totalBudget) : 0;
        double expenseProgress = totalBudget > 0 ? (totalExpense / totalBudget) : 0;

        // Number formatter for currency
        final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

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
                  currencyFormat.format(currentBalance),
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                // Income
                _buildBalanceBar(
                  context: context,
                  label: 'Thu nhập',
                  amount: currencyFormat.format(totalIncome),
                  progress: incomeProgress,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                // Expense
                _buildBalanceBar(
                  context: context,
                  label: 'Chi tiêu',
                  amount: currencyFormat.format(totalExpense),
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

  // Helper for Income/Expense bars
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
          backgroundColor: color.withOpacity(0.2),
          color: color,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  // Widget for transaction list
  Widget _buildTransactionList(DatabaseService dbService) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return StreamBuilder<List<TransactionModel>>(
      stream: dbService.getTransactionsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(child: Center(child: Text('Error: ${snapshot.error}')));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('Bạn chưa có giao dịch nào.')),
            ),
          );
        }

        final transactions = snapshot.data!;
        // We don't group by date here for simplicity, but you could add that logic.
        
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final txn = transactions[index];
              final isIncome = txn.type == TransactionType.income;
              
              return ListTile(
                leading: CircleAvatar(
                  // TODO: Map txn.category to an Icon
                  child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward),
                ),
                title: Text(txn.category),
                subtitle: Text(dateFormat.format(txn.date)),
                trailing: Text(
                  '${isIncome ? '+' : '-'}${currencyFormat.format(txn.amount)}',
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
            childCount: transactions.length,
          ),
        );
      },
    );
  }
}

// Helper delegate for sticky headers
class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  _SectionHeaderDelegate(this.title);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.grey[50], // Match scaffold bg
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