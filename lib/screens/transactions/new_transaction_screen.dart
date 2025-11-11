import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:personal_finance_app_flutter/widgets/custom_text_field.dart';

class NewTransactionScreen extends StatefulWidget {
  final String category;
  final String type; // 'expense' or 'income'

  const NewTransactionScreen({
    super.key, 
    required this.category, 
    required this.type
  });

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set initial date in the text field
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }

  Future<void> _saveTransaction() async {
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
      final amount = double.parse(_amountController.text);
      final notes = _notesController.text;

      final newTransaction = TransactionModel(
        category: widget.category,
        type: widget.type,
        amount: amount,
        date: Timestamp.fromDate(_selectedDate),
        notes: notes,
      );

      await DatabaseService(userId: user.uid).addTransaction(newTransaction);

      if (mounted) {
        // Pop twice to go back to the home screen (past the category screen)
        Navigator.pop(context);
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save transaction: ${e.toString()}')),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category (read-only)
              TextFormField(
                initialValue: widget.category,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  // TODO: Add dynamic icon based on category
                  prefixIcon: Icon(Icons.category), 
                  border: OutlineInputBorder(),
                  filled: false,
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _amountController,
                hintText: 'Số tiền',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val!.isEmpty) return 'Vui lòng nhập số tiền';
                  if (double.tryParse(val) == null) return 'Số tiền không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _dateController,
                hintText: 'Ngày',
                prefixIcon: Icons.calendar_today,
                readOnly: true,
                onTap: _showDatePicker, // Show date picker on tap
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _notesController,
                hintText: 'Ghi chú',
                prefixIcon: Icons.notes,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // 2. Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveTransaction,
                      child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                          : const Text('Thêm'),
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