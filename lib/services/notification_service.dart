// =======================================================================
// lib/services/notification_service.dart
// (UPDATED)
// =======================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_finance_app_flutter/models/budget_model.dart';
import 'package:personal_finance_app_flutter/models/notification_model.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart'; 
// --- NEW: Add missing import ---
import 'package:personal_finance_app_flutter/utils/currency_formatter.dart';
// --- END OF NEW ---

class NotificationService {
  final DatabaseService dbService;
  NotificationService({required this.dbService});

  // Main function to check all budgets and create alerts
  Future<void> checkBudgets(
    List<Budget> budgets, // This list is pre-filtered by budget_screen
    List<TransactionModel> transactions,
  ) async {
    if (budgets.isEmpty) return;

    // Group transactions by category and sum their amounts
    final Map<String, double> categorySpending =
        groupBy(transactions, (txn) => txn.category)
            .map((category, txns) => MapEntry(
                  category,
                  txns.where((txn) => txn.type == 'expense') // Only sum expenses
                      .fold(0.0, (sum, txn) => sum + txn.amount),
                ));

    // Check each budget against the spending
    for (final budget in budgets) {
      final double spent = categorySpending[budget.category] ?? 0.0;
      // Ensure budget amount is not zero to avoid division by zero
      if (budget.amount == 0) continue;

      final double percentage = (spent / budget.amount) * 100;

      // --- FIX: Implement 70%, 85%, 100% logic ---

      // --- 1. Check for EXCEEDED budget ---
      if (percentage >= 100) {
        final double overAmount = spent - budget.amount;
        final notification = AppNotification(
          id: const Uuid().v4(), // Generate a unique ID
          title: "ĐÃ VƯỢT NGÂN SÁCH!",
          body:
              "Bạn đã vượt quá ngân sách cho '${budget.category}' ${CurrencyFormatter.format(overAmount)} (${percentage.toStringAsFixed(0)}%).",
          type: NotificationType.exceeded, // Red warning
          createdAt: Timestamp.now(),
        );
        // Add to database
        await dbService.addNotification(notification);
      }
      // --- 2. Check for Strong WARNING (85% or more) ---
      else if (percentage >= 85) {
        final notification = AppNotification(
          id: const Uuid().v4(), // Generate a unique ID
          title: "Cảnh báo ngân sách!",
          body:
              "Bạn đã chi ${percentage.toStringAsFixed(0)}% ngân sách cho '${budget.category}'. Hãy cẩn thận!",
          type: NotificationType.warning, // Strong warning
          createdAt: Timestamp.now(),
        );
        // Add to database
        await dbService.addNotification(notification);
      }
      // --- 3. Check for Mild WARNING (70% or more) ---
      else if (percentage >= 70) {
         final notification = AppNotification(
          id: const Uuid().v4(), // Generate a unique ID
          title: "Thông báo ngân sách",
          body:
              "Bạn đã chi ${percentage.toStringAsFixed(0)}% ngân sách cho '${budget.category}'.",
          type: NotificationType.warning, // Mild warning
          createdAt: Timestamp.now(),
        );
        // Add to database
        await dbService.addNotification(notification);
      }
      // --- END OF FIX ---
    }
  }
}