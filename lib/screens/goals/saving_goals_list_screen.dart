import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart';
import 'package:personal_finance_app_flutter/routes.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _authService = AuthService();
    final user = _authService.currentUser;

    if (user == null) {
      // This should not happen if AuthWrapper is working, but as a fallback.
      return const Scaffold(body: Center(child: Text('User not found.')));
    }

    // Initialize database service with the user's ID
    final _dbService = DatabaseService(userId: user.uid);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. Header with Sign Out
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.grey[50],
              elevation: 0,
              title: CircleAvatar(
                child: const Icon(Icons.person),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sign Out',
                  onPressed: () async {
                    await _authService.signOut();
                    // AuthWrapper will handle navigation
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Profile Settings',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.editProfile);
                  },
                ),
              ],
            ),
            
            // 2. Account Summary Card (still static, needs logic)
            SliverToBoxAdapter(
              child: _buildAccountSummaryCard(context),
            ),

            // 3. Transaction History List (now real-time)
            SliverPersistentHeader(
              pinned: true,
              delegate: _SectionHeaderDelegate('Lịch sử giao dịch'),
            ),
            // Use a StreamBuilder to show real-time transactions
            StreamBuilder<List<TransactionModel>>(
              stream: _dbService.getTransactionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: Text('Chưa có giao dịch nào.')),
                    ),
                  );
                }

                // We have data, build the list
                final transactions = snapshot.data!;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final txn = transactions[index];
                      final isIncome = txn.type == 'income';
                      final dateString = DateFormat('dd/MM/yyyy').format(txn.date.toDate());

                      return ListTile(
                        leading: CircleAvatar(
                          // TODO: Map txn.category to an Icon
                          child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward),
                        ),
                        title: Text(txn.category),
                        subtitle: Text(txn.notes.isNotEmpty ? txn.notes : dateString),
                        trailing: Text(
                          '${isIncome ? '+' : '-'}${txn.amount.toStringAsFixed(0)} đ',
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
            ),
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

  // ... (Keep _buildAccountSummaryCard and _SectionHeaderDelegate as they are)
  
  // Widget for the summary card
  Widget _buildAccountSummaryCard(BuildContext context) {
    // TODO: This data should also come from the database,
    // possibly by summarizing transactions.
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
              '15,000,000 đ', // Static data
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
              amount: '20,000,000 đ',
              progress: 0.8,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            // Expense
            _buildBalanceBar(
              context: context,
              label: 'Chi tiêu',
              amount: '5,000,000 đ',
              progress: 0.2,
              color: Colors.red,
            ),
          ],
        ),
      ),
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