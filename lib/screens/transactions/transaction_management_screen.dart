import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart';
import 'package:personal_finance_app_flutter/routes.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:personal_finance_app_flutter/utils/currency_formatter.dart'; // Import formatter
import 'package:personal_finance_app_flutter/widgets/category_icon.dart';

class TransactionManagementScreen extends StatelessWidget {
  const TransactionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in.")));
    }

    final dbService = DatabaseService(userId: user.uid);
    final DateFormat displayFormatter = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý giao dịch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: dbService.getTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có giao dịch nào.'));
          }
          final transactions = snapshot.data!;

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final txn = transactions[index];
              return Dismissible(
                key: Key(txn.id!),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  dbService.deleteTransaction(txn.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Đã xoá giao dịch "${txn.category}"')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: CategoryIcon(category: txn.category),
                  ),
                  title: Text(txn.category),
                  subtitle: Text(
                      "${txn.notes.isNotEmpty ? '${txn.notes}\n' : ''}${displayFormatter.format(txn.date.toDate())}"),
                  isThreeLine: txn.notes.isNotEmpty,
                  trailing: Text(
                    '${txn.type == 'income' ? '+' : '-'}${CurrencyFormatter.format(txn.amount)}', // <-- USE FORMATTER
                    style: TextStyle(
                      color: txn.type == 'income' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // TODO: Navigate to edit transaction
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.categorySelect);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}