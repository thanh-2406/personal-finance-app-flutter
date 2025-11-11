import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_finance_app_flutter/models/goal_model.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart';

class DatabaseService {
  final String userId;
  DatabaseService({required this.userId});

  // Firestore instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections References
  CollectionReference<Goal> get _goalsCollection => _db
      .collection('users')
      .doc(userId)
      .collection('goals')
      .withConverter<Goal>(
        fromFirestore: (snapshot, _) => Goal.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (goal, _) => goal.toJson(),
      );
  
  CollectionReference<TransactionModel> get _txnsCollection => _db
      .collection('users')
      .doc(userId)
      .collection('transactions')
      .withConverter<TransactionModel>(
        fromFirestore: (snapshot, _) => TransactionModel.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (txn, _) => txn.toJson(),
      );

  // --- Goals CRUD ---

  // Create (Add)
  Future<void> addGoal(Goal goal) {
    return _goalsCollection.add(goal);
  }

  // Read (Stream)
  Stream<List<Goal>> getGoalsStream() {
    return _goalsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Update
  Future<void> updateGoal(Goal goal) {
    if (goal.id == null) throw Exception("Goal ID is null, cannot update");
    return _goalsCollection.doc(goal.id).update(goal.toJson());
  }

  // Delete
  Future<void> deleteGoal(String goalId) {
    return _goalsCollection.doc(goalId).delete();
  }

  // --- Transactions CRUD ---

  // Create (Add)
  Future<void> addTransaction(TransactionModel txn) {
    return _txnsCollection.add(txn);
  }

  // Read (Stream)
  Stream<List<TransactionModel>> getTransactionsStream() {
    // Order by date, most recent first
    return _txnsCollection.orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Update
  Future<void> updateTransaction(TransactionModel txn) {
    if (txn.id == null) throw Exception("Transaction ID is null, cannot update");
    return _txnsCollection.doc(txn.id).update(txn.toJson());
  }

  // Delete
  Future<void> deleteTransaction(String txnId) {
    return _txnsCollection.doc(txnId).delete();
  }
}