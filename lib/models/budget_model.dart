import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  String? id;
  String category;
  double amount;
  String monthYear; // Format: "MM-YYYY" e.g., "11-2025"

  Budget({
    this.id,
    required this.category,
    required this.amount,
    required this.monthYear,
  });

  // Convert to a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'monthYear': monthYear,
    };
  }

  // --- THIS IS THE FIX ---
  // Create from a Firestore DocumentSnapshot
  factory Budget.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return Budget(
      id: doc.id,
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      monthYear: map['monthYear'],
    );
  }

  // A copyWith method to make editing easier
  Budget copyWith({
    String? id,
    String? category,
    double? amount,
    String? monthYear,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      monthYear: monthYear ?? this.monthYear,
    );
  }
}