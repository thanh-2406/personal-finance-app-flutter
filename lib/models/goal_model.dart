class Goal {
  String? id; // Firestore document ID
  final String name;
  final double targetAmount;
  final double currentAmount;

  Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
  });

  // Factory constructor to create a Goal from JSON (Firestore data)
  factory Goal.fromJson(Map<String, dynamic> json, String id) {
    return Goal(
      id: id,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
    );
  }

  // Method to convert a Goal object to JSON (for writing to Firestore)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
    };
  }

  // Helper method to create a copy of a Goal with updated values
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