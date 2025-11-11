import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/models/goal_model.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:personal_finance_app_flutter/widgets/custom_text_field.dart';

class AddNewGoalScreen extends StatefulWidget {
  const AddNewGoalScreen({super.key});

  @override
  State<AddNewGoalScreen> createState() => _AddNewGoalScreenState();
}

class _AddNewGoalScreenState extends State<AddNewGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
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
      final name = _nameController.text;
      final targetAmount = double.parse(_targetAmountController.text);

      final newGoal = Goal(
        name: name,
        targetAmount: targetAmount,
        currentAmount: 0.0, // New goals start at 0
      );

      await DatabaseService(userId: user.uid).addGoal(newGoal);

      if (mounted) Navigator.pop(context);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save goal: ${e.toString()}')),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm mục tiêu mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Form Fields
              CustomTextField(
                controller: _nameController,
                hintText: 'Tên mục tiêu (ví dụ: Mua Laptop)',
                validator: (val) => val!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _targetAmountController,
                hintText: 'Số tiền mục tiêu (ví dụ: 25000000)',
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
                      onPressed: _isLoading ? null : _saveGoal,
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