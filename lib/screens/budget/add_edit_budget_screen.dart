import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app_flutter/models/budget_model.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:personal_finance_app_flutter/widgets/custom_text_field.dart';

class AddEditBudgetScreen extends StatefulWidget {
  final Budget? budget; // Null if adding, has value if editing

  const AddEditBudgetScreen({super.key, this.budget});

  @override
  State<AddEditBudgetScreen> createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends State<AddEditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  String? _selectedCategory;
  bool _isLoading = false;
  
  // We'll hardcode the month for now to the current month
  final String _monthYear = DateFormat('MM-yyyy').format(DateTime.now());

  // Dummy list of categories. In a real app, this might come from a DB
  final List<String> _expenseCategories = [
    'Ăn uống',
    'Du lịch',
    'Chữa bệnh',
    'Di chuyển',
    'Mua sắm',
    'Giải trí',
    'Hoá đơn',
    'Khác'
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.budget?.category;
    _amountController =
        TextEditingController(text: widget.budget?.amount.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một danh mục')),
      );
      return;
    }

    final user = AuthService().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are not logged in!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      
      final budget = Budget(
        id: widget.budget?.id, // Will be null if adding
        category: _selectedCategory!,
        amount: amount,
        monthYear: _monthYear, // Using the current month
      );

      final dbService = DatabaseService(userId: user.uid);
      if (widget.budget == null) {
        // Add new budget
        await dbService.addBudget(budget);
      } else {
        // Update existing budget
        await dbService.updateBudget(budget);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu ngân sách: $e')),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Thêm ngân sách' : 'Sửa ngân sách'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Chọn danh mục'),
                items: _expenseCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Vui lòng chọn danh mục' : null,
              ),
              const SizedBox(height: 16),
              
              // 2. Amount Field
              CustomTextField(
                controller: _amountController,
                hintText: 'Số tiền (ví dụ: 5000000)',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Vui lòng nhập một số hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. Month/Year (Read-only for now)
              TextFormField(
                initialValue: "Ngân sách cho tháng: $_monthYear",
                readOnly: true,
                decoration: InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.calendar_today),
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 32),

              // 4. Save Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveBudget,
                      child: const Text('Lưu'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}