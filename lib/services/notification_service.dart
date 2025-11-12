import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_finance_app_flutter/models/budget_model.dart';
import 'package:personal_finance_app_flutter/models/notification_model.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart'; // Import collection package

class NotificationService {
  final DatabaseService dbService;
  NotificationService({required this.dbService});

  // Main function to check all budgets and create alerts
  Future<void> checkBudgets(
    List<Budget> budgets,
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
      final double percentage = (spent / budget.amount) * 100;

      // --- 1. Check for EXCEEDED budget ---
      if (percentage >= 100) {
        final double overAmount = spent - budget.amount;
        final notification = AppNotification(
          id: const Uuid().v4(), // Generate a unique ID
          title: "Đã vượt quá ngân sách!",
          body:
              "Bạn đã vượt quá ngân sách cho '${budget.category}' ${overAmount.toStringAsFixed(0)} đ (${percentage.toStringAsFixed(0)}%).",
          type: NotificationType.exceeded,
          createdAt: Timestamp.now(),
        );
        // Add to database
        await dbService.addNotification(notification);
      }
      // --- 2. Check for WARNING (90% or more) ---
      else if (percentage >= 90) {
        final notification = AppNotification(
          id: const Uuid().v4(), // Generate a unique ID
          title: "Sắp vượt ngân sách!",
          body:
              "Bạn đã chi ${percentage.toStringAsFixed(0)}% ngân sách cho '${budget.category}'. Hãy cẩn thận!",
          type: NotificationType.warning,
          createdAt: Timestamp.now(),
        );
        // Add to database
        await dbService.addNotification(notification);
      }
    }
  }
}