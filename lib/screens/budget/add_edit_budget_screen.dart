// =======================================================================
// lib/screens/budget/add_edit_budget_screen.dart
// (UPDATED)
// =======================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app_flutter/models/budget_model.dart';
import 'package:personal_finance_app_flutter/models/budget_period.dart';
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
  late TextEditingController _dateRangeController;
  String? _selectedCategory;
  bool _isLoading = false;

  // --- NEW FIELDS FOR PERIOD ---
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  DateTime _selectedDate = DateTime.now(); // For daily
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  // --- END OF NEW FIELDS ---

  final List<String> _expenseCategories = [
    'Food',
    'Health',
    'Travel',
    'Shopping',
    'Bills',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.budget?.amount.toStringAsFixed(0) ?? '');
    _dateRangeController = TextEditingController();

    if (widget.budget != null) {
      _selectedCategory = widget.budget!.category;
      _selectedPeriod = widget.budget!.period;
      _startDate = widget.budget!.startDate.toDate();
      _endDate = widget.budget!.endDate?.toDate();
    } else {
      // Set defaults for a new budget
      _initializeDatesForPeriod(BudgetPeriod.monthly);
    }
    _updateDateRangeText();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateRangeController.dispose();
    super.dispose();
  }

  // --- NEW: Helper to set dates based on period ---
  void _initializeDatesForPeriod(BudgetPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case BudgetPeriod.daily:
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = null;
        break;
      case BudgetPeriod.weekly:
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = _startDate.add(const Duration(days: 6));
        break;
      case BudgetPeriod.monthly:
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case BudgetPeriod.custom:
        _startDate = now;
        _endDate = now.add(const Duration(days: 7));
        break;
    }
    _updateDateRangeText();
  }

  // --- NEW: Helper to show custom date range picker ---
  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate ?? _startDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _updateDateRangeText();
      });
    }
  }

  // --- NEW: Helper to update the text field ---
  void _updateDateRangeText() {
    final formatter = DateFormat('dd/MM/yyyy');
    if (_selectedPeriod == BudgetPeriod.daily) {
      _dateRangeController.text = formatter.format(_startDate);
    } else if (_selectedPeriod == BudgetPeriod.custom) {
      _dateRangeController.text =
          '${formatter.format(_startDate)} - ${formatter.format(_endDate ?? _startDate)}';
    } else if (_selectedPeriod == BudgetPeriod.weekly) {
      _dateRangeController.text =
          '${formatter.format(_startDate)} - ${formatter.format(_endDate ?? _startDate)}';
    } else {
      _dateRangeController.text =
          DateFormat('MMMM yyyy', 'vi_VN').format(_startDate);
    }
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
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      
      // --- UPDATED: Create budget with new period logic ---
      final budget = Budget(
        id: widget.budget?.id,
        category: _selectedCategory!,
        amount: amount,
        period: _selectedPeriod,
        startDate: Timestamp.fromDate(_startDate),
        endDate: _endDate != null ? Timestamp.fromDate(_endDate!) : null,
      );
      // --- END OF UPDATE ---

      final dbService = DatabaseService(userId: user.uid);
      if (widget.budget == null) {
        await dbService.addBudget(budget);
      } else {
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
              const SizedBox(height: 24),

              // --- NEW: Period Selector ---
              const Text('Kỳ ngân sách', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<BudgetPeriod>(
                value: _selectedPeriod,
                items: BudgetPeriod.values.map((period) {
                  return DropdownMenuItem<BudgetPeriod>(
                    value: period,
                    child: Text(getPeriodDisplayName(period)),
                  );
                }).toList(),
                onChanged: (BudgetPeriod? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedPeriod = newValue;
                      if (newValue != BudgetPeriod.custom) {
                         _initializeDatesForPeriod(newValue);
                      }
                    });
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              const SizedBox(height: 16),
              
              // --- NEW: Date Range Field ---
              CustomTextField(
                controller: _dateRangeController,
                hintText: 'Thời gian',
                prefixIcon: Icons.calendar_today,
                readOnly: true,
                onTap: () {
                  if (_selectedPeriod == BudgetPeriod.custom) {
                    _showDateRangePicker();
                  }
                  // Optional: allow changing date for daily/weekly too
                },
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