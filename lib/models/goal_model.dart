import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  String? id;
  String name;
  double targetAmount;
  double currentAmount;

  Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
  });

  // Convert to a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
    };
  }

  // Create from a Firestore DocumentSnapshot
  factory Goal.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return Goal(
      id: doc.id,
      name: map['name'],
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num).toDouble(),
    );
  }

  // --- THIS IS THE FIX ---
  // Add the missing copyWith method
  Goal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
    );
  }
}