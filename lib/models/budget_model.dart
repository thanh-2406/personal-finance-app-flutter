// =======================================================================
// lib/models/budget_model.dart
// (UPDATED)
// =======================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_finance_app_flutter/models/budget_period.dart';

class Budget {
  String? id;
  String category;
  double amount;
  
  // --- UPDATED FIELDS ---
  BudgetPeriod period;    // e.g., daily, weekly, monthly, custom
  Timestamp startDate;    // The start date of this budget period
  Timestamp? endDate;     // The end date (null for daily, weekly, monthly)
  // --- END OF UPDATE ---

  Budget({
    this.id,
    required this.category,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
  });

  // Convert to a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'period': period.name, // Save enum as a string
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  // Create from a Firestore DocumentSnapshot
  factory Budget.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return Budget(
      id: doc.id,
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      // --- UPDATED FIELDS ---
      period: periodFromString(map['period']), // Use helper
      startDate: map['startDate'] as Timestamp,
      endDate: map['endDate'] as Timestamp?,
      // --- END OF UPDATE ---
    );
  }

  // A copyWith method to make editing easier
  Budget copyWith({
    String? id,
    String? category,
    double? amount,
    BudgetPeriod? period,
    Timestamp? startDate,
    Timestamp? endDate,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}