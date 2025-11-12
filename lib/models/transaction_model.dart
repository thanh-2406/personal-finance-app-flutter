import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String? id;
  String category;
  double amount;
  Timestamp date; // Use Timestamp for Firestore
  String notes;
  String type; // 'income' or 'expense'

  TransactionModel({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.notes = '',
    required this.type,
  });

  // Convert to a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'date': date,
      'notes': notes,
      'type': type,
    };
  }

  // --- THIS IS THE FIX ---
  // Create from a Firestore DocumentSnapshot
  factory TransactionModel.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id, // Get the ID from the document itself
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as Timestamp, // Get as Timestamp
      notes: map['notes'] ?? '',
      type: map['type'],
    );
  }
}