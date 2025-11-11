import 'package:cloud_firestore/cloud_firestore.dart';

// THIS IS THE ENUM THE COMPILER IS LOOKING FOR
enum TransactionType {
  income,
  expense,
}

class TransactionModel {
  String? id;
  String category;
  double amount;
  DateTime date;
  String notes;
  TransactionType type;

  TransactionModel({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.notes = '',
    required this.type,
  });

  // Helper function to convert enum to string
  String get typeAsString {
    return type == TransactionType.income ? 'income' : 'expense';
  }

  // Helper function to convert string to enum
  static TransactionType typeFromString(String typeStr) {
    return typeStr == 'income' ? TransactionType.income : TransactionType.expense;
  }

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'type': typeAsString, // Store as a string
    };
  }

  // Create from a Firestore document
  factory TransactionModel.fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      notes: map['notes'] ?? '',
      type: typeFromString(map['type']), // Read string and convert to enum
    );
  }
}