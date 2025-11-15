// =======================================================================
// lib/services/database_service.dart
// (UPDATED)
// =======================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_finance_app_flutter/models/budget_model.dart';
import 'package:personal_finance_app_flutter/models/goal_model.dart';
import 'package:personal_finance_app_flutter/models/notification_model.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart';

class DatabaseService {
  final String userId;
  DatabaseService({required this.userId});

  // Main collection reference
  CollectionReference get usersCollection =>
      FirebaseFirestore.instance.collection('users');

  // Path for user-specific data
  DocumentReference get userDocument => usersCollection.doc(userId);

  // --- User Settings (NEW) ---
  
  // Document reference for user settings
  DocumentReference get settingsDocument => userDocument.collection('settings').doc('userSettings');

  // Get user notification settings stream
  Stream<bool> getUserNotificationSettingsStream() {
    return settingsDocument.snapshots().map((doc) {
      if (doc.exists && (doc.data() as Map<String, dynamic>).containsKey('notificationsEnabled')) {
        return (doc.data() as Map<String, dynamic>)['notificationsEnabled'] as bool;
      }
      return true; // Default to true if not set
    });
  }

  // Update user notification settings
  Future<void> updateUserNotificationSettings(bool isEnabled) {
    return settingsDocument.set({
      'notificationsEnabled': isEnabled,
    }, SetOptions(merge: true)); // Merge to avoid overwriting other settings
  }

  // --- Transactions ---

  CollectionReference get transactionsCollection =>
      userDocument.collection('transactions');

  // Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) {
    return transactionsCollection.add(transaction.toJson());
  }

  // Get a stream of transactions
  Stream<List<TransactionModel>> getTransactionsStream() {
    return transactionsCollection.orderBy('date', descending: true).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc)) 
            .toList());
  }

  // Get transactions within a date range (for statistics)
  Stream<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end) {
    // Ensure the end time includes the whole day
    final inclusiveEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return transactionsCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(inclusiveEnd))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc)) 
            .toList());
  }

  // Delete a transaction
  Future<void> deleteTransaction(String transactionId) {
    return transactionsCollection.doc(transactionId).delete();
  }

  // --- Goals ---

  CollectionReference get goalsCollection => userDocument.collection('goals');

  // Add a new goal
  Future<void> addGoal(Goal goal) {
    return goalsCollection.add(goal.toJson());
  }

  // Get a stream of goals
  Stream<List<Goal>> getGoalsStream() {
    return goalsCollection.snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Goal.fromJson(doc)).toList()); 
  }

  // Update a goal
  Future<void> updateGoal(Goal goal) {
    return goalsCollection.doc(goal.id).update(goal.toJson());
  }

  // Delete a goal
  Future<void> deleteGoal(String goalId) {
    return goalsCollection.doc(goalId).delete();
  }

  // --- Budgets (UPDATED) ---

  CollectionReference get budgetsCollection => userDocument.collection('budgets');

  // Add a new budget
  Future<void> addBudget(Budget budget) {
    return budgetsCollection.add(budget.toJson());
  }

  // Get ALL budgets, ordered by start date
  Stream<List<Budget>> getBudgetsStream() {
    return budgetsCollection
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Budget.fromJson(doc)).toList());
  }
  // --- END OF UPDATE ---

  // Update a budget
  Future<void> updateBudget(Budget budget) {
    return budgetsCollection.doc(budget.id).update(budget.toJson());
  }

  // Delete a budget
  Future<void> deleteBudget(String budgetId) {
    return budgetsCollection.doc(budgetId).delete();
  }

  // --- Notifications (NEW) ---

  CollectionReference get notificationsCollection =>
      userDocument.collection('notifications');

  // Add a new notification (used by NotificationService)
  Future<void> addNotification(AppNotification notification) {
    return notificationsCollection
        .doc(notification.id)
        .set(notification.toJson());
  }

  // Get a stream of unread notifications
  Stream<List<AppNotification>> getNotificationsStream() {
    return notificationsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromJson(doc)) 
            .toList());
  }

  // Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) {
    return notificationsCollection.doc(notificationId).update({'isRead': true});
  }
}