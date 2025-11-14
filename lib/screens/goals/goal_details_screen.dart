import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app_flutter/models/goal_model.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:personal_finance_app_flutter/utils/currency_formatter.dart';
import 'package:personal_finance_app_flutter/widgets/custom_text_field.dart';

class GoalDetailsScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailsScreen({super.key, required this.goal});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Function to show the "Add/Subtract" dialog
  void _showUpdateDialog(bool isAdding, Goal currentGoal) {
    _amountController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isAdding ? 'Thêm tiền vào mục tiêu' : 'Rút tiền từ mục tiêu'),
          content: Form(
            key: _formKey,
            child: CustomTextField(
              controller: _amountController,
              hintText: 'Số tiền',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Vui lòng nhập số tiền';
                if (double.tryParse(val) == null || double.parse(val) <= 0) {
                  return 'Số tiền không hợp lệ';
                }
                if (!isAdding && double.parse(val) > currentGoal.currentAmount) {
                  return 'Số tiền rút vượt quá số tiền hiện có';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final amount = double.parse(_amountController.text);
                  // Pass the 'currentGoal' from the stream to update from
                  _updateGoalSaving(amount, currentGoal: currentGoal, isAdding: isAdding);
                  Navigator.pop(context);
                }
              },
              child: Text(isAdding ? 'Thêm' : 'Rút'),
            ),
          ],
        );
      },
    );
  }

  // Function to update the goal AND create a transaction
  Future<void> _updateGoalSaving(double amount, {required Goal currentGoal, required bool isAdding}) async {
    final user = AuthService().currentUser;
    if (user == null) return;
    
    final dbService = DatabaseService(userId: user.uid);

    try {
      // 1. Update the goal's current amount
      final newCurrentAmount = isAdding
          ? currentGoal.currentAmount + amount
          : currentGoal.currentAmount - amount;

      await dbService.updateGoal(
        currentGoal.copyWith(currentAmount: newCurrentAmount),
      );

      // 2. Create a corresponding transaction
      final transaction = TransactionModel(
        category: 'Mục tiêu: ${currentGoal.name}',
        type: isAdding ? 'expense' : 'income', 
        amount: amount,
        date: Timestamp.now(),
        notes: isAdding ? 'Thêm tiền vào mục tiêu' : 'Rút tiền từ mục tiêu',
      );
      await dbService.addTransaction(transaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật mục tiêu!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal.name),
      ),
      // --- FIX: Refactored to prevent flicker ---
      // The SingleChildScrollView is now the base
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Progress Card (now in its own StreamBuilder)
            _buildGoalProgressCard(context),
            
            const SizedBox(height: 16),
            
            // 2. Info Section (static)
            if (widget.goal.deadline != null)
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Ngày hết hạn'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(widget.goal.deadline!.toDate())),
              ),
            if (widget.goal.isImportant)
              const ListTile(
                leading: Icon(Icons.star_outlined, color: Colors.amber),
                title: Text('Mục tiêu quan trọng'),
              ),
            const Divider(),
            
            // 3. Action Buttons are now inside _buildGoalProgressCard
            
            const SizedBox(height: 24),
            
            // 4. Transaction History (in its own StreamBuilder, now stable)
            Text(
              'Lịch sử giao dịch mục tiêu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            _buildGoalTransactionList(context, widget.goal.name),
          ],
        ),
      ),
    );
  }

  // --- NEW WIDGET: Handles dynamic goal progress and buttons ---
  Widget _buildGoalProgressCard(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: DatabaseService(userId: AuthService().currentUser!.uid)
          .goalsCollection
          .doc(widget.goal.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        final Goal goal = Goal.fromJson(snapshot.data!);
        final progress = (goal.targetAmount > 0) 
            ? (goal.currentAmount / goal.targetAmount) 
            : 0.0;
        final bool isCompleted = progress >= 1.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: isCompleted ? Colors.green.shade50 : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (isCompleted)
                      Text(
                        'ĐÃ HOÀN THÀNH MỤC TIÊU!',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    else
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                      color: isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đã tiết kiệm',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Mục tiêu',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          CurrencyFormatter.format(goal.currentAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          CurrencyFormatter.format(goal.targetAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            if (!isCompleted)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showUpdateDialog(false, goal),
                      icon: const Icon(Icons.remove),
                      label: const Text('Rút tiền'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showUpdateDialog(true, goal),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm tiền'),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
  // --- END OF NEW WIDGET ---

  Widget _buildGoalTransactionList(BuildContext context, String goalName) {
    final dbService = DatabaseService(userId: AuthService().currentUser!.uid);
    final categoryString = 'Mục tiêu: $goalName';

    return StreamBuilder<List<TransactionModel>>(
      stream: dbService.transactionsCollection
          .where('category', isEqualTo: categoryString)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromJson(doc))
              .toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Changed to a smaller indicator since it's part of a list
          return const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Chưa có lịch sử giao dịch cho mục tiêu này.'),
            ),
          );
        }
        final transactions = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final txn = transactions[index];
            final bool isAdding = txn.type == 'expense'; // 'expense' = added to goal
            return Card(
              elevation: 0,
              color: Colors.grey.shade100,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    isAdding ? Icons.add_circle : Icons.remove_circle,
                    color: isAdding ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(isAdding ? 'Thêm tiền vào mục tiêu' : 'Rút tiền từ mục tiêu'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(txn.date.toDate())),
                trailing: Text(
                  '${isAdding ? '+' : '-'}${CurrencyFormatter.format(txn.amount)}',
                  style: TextStyle(
                    color: isAdding ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}