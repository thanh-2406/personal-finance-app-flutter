import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app_flutter/models/goal_model.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:personal_finance_app_flutter/widgets/custom_text_field.dart';

class AddEditGoalScreen extends StatefulWidget {
  final Goal? goal;

  const AddEditGoalScreen({super.key, this.goal});

  @override
  State<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  late TextEditingController _deadlineController;
  
  DateTime? _selectedDeadline;
  bool _isImportant = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _targetAmountController = TextEditingController(
        text: widget.goal?.targetAmount.toStringAsFixed(0) ?? '');
    _currentAmountController = TextEditingController(
        text: widget.goal?.currentAmount.toStringAsFixed(0) ?? '0');
    _isImportant = widget.goal?.isImportant ?? false;
    _selectedDeadline = widget.goal?.deadline?.toDate();
    
    _deadlineController = TextEditingController(
      text: _selectedDeadline != null 
          ? DateFormat('dd/MM/yyyy').format(_selectedDeadline!) 
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDeadline = pickedDate;
        _deadlineController.text = DateFormat('dd/MM/yyyy').format(_selectedDeadline!);
      });
    }
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
      final currentAmount = double.parse(_currentAmountController.text);

      final goal = Goal(
        id: widget.goal?.id,
        name: name,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        isImportant: _isImportant,
        deadline: _selectedDeadline != null 
            ? Timestamp.fromDate(_selectedDeadline!) 
            : null,
      );

      final dbService = DatabaseService(userId: user.uid);
      if (widget.goal == null) {
        await dbService.addGoal(goal);
      } else {
        await dbService.updateGoal(goal);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu mục tiêu: $e')),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool canEditCurrentAmount = widget.goal == null;
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? 'Thêm mục tiêu mới' : 'Sửa mục tiêu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Tên mục tiêu', style: labelStyle), // <--- ADDED TITLE
              const SizedBox(height: 8),
              CustomTextField(
                controller: _nameController,
                hintText: 'Ví dụ: Mua Laptop',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              
              Text('Số tiền mục tiêu', style: labelStyle), // <--- ADDED TITLE
              const SizedBox(height: 8),
              CustomTextField(
                controller: _targetAmountController,
                hintText: 'Ví dụ: 25000000',
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Vui lòng nhập số tiền';
                  if (double.tryParse(val) == null || double.parse(val) <= 0) {
                    return 'Vui lòng nhập số tiền hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              if (canEditCurrentAmount) ...[
                Text('Số tiền ban đầu', style: labelStyle), // <--- ADDED TITLE
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _currentAmountController,
                  hintText: 'Ví dụ: 0',
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Vui lòng nhập số tiền';
                    if (double.tryParse(val) == null || double.parse(val) < 0) {
                      return 'Vui lòng nhập số tiền hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              Text('Ngày hết hạn', style: labelStyle), // <--- ADDED TITLE
              const SizedBox(height: 8),
              CustomTextField(
                controller: _deadlineController,
                hintText: 'Chọn ngày (Tùy chọn)',
                prefixIcon: Icons.calendar_today,
                readOnly: true,
                onTap: _showDatePicker,
              ),
              const SizedBox(height: 16),
              
              SwitchListTile(
                title: const Text('Đánh dấu là mục tiêu quan trọng'),
                value: _isImportant,
                onChanged: (bool value) {
                  setState(() {
                    _isImportant = value;
                  });
                },
                secondary: const Icon(Icons.star_border),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveGoal,
                      child: const Text('Lưu mục tiêu'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}