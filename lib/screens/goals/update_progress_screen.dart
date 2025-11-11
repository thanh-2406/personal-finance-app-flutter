import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/models/goal_model.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:personal_finance_app_flutter/widgets/custom_text_field.dart';

class UpdateProgressScreen extends StatefulWidget {
  final Goal goal;
  const UpdateProgressScreen({super.key, required this.goal});

  @override
  State<UpdateProgressScreen> createState() => _UpdateProgressScreenState();
}

class _UpdateProgressScreenState extends State<UpdateProgressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the text field with the current saved amount
    _amountController.text = widget.goal.currentAmount.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _updateGoal() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = AuthService().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are not logged in!')),
      );
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      final newAmount = double.parse(_amountController.text);
      if (newAmount > widget.goal.targetAmount) {
        // Optional: Show a confirmation if they exceed the goal
      }

      // Create an updated copy of the goal
      final updatedGoal = widget.goal.copyWith(currentAmount: newAmount);

      await DatabaseService(userId: user.uid).updateGoal(updatedGoal);

      if (mounted) Navigator.pop(context);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update goal: ${e.toString()}')),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật tiến độ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Goal Name (read-only)
              TextFormField(
                initialValue: widget.goal.name,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tên mục tiêu',
                  border: OutlineInputBorder(),
                  filled: false,
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // New Saved Amount
              CustomTextField(
                controller: _amountController,
                hintText: 'Số tiền đã tiết kiệm mới',
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val!.isEmpty) return 'Vui lòng nhập số tiền';
                  if (double.tryParse(val) == null) return 'Số tiền không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // 2. Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateGoal,
                      child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                          : const Text('Lưu'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}