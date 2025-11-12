import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  warning,
  exceeded,
}

class AppNotification {
  String id;
  String title;
  String body;
  NotificationType type;
  Timestamp createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  // Helper to convert enum to string
  String get typeAsString {
    return type == NotificationType.warning ? 'warning' : 'exceeded';
  }

  // Helper to convert string to enum
  static NotificationType typeFromString(String typeStr) {
    return typeStr == 'warning' ? NotificationType.warning : NotificationType.exceeded;
  }

  // Convert to a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': typeAsString,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }

  // --- THIS IS THE FIX ---
  // Create from a Firestore DocumentSnapshot
  factory AppNotification.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      type: typeFromString(map['type']),
      createdAt: map['createdAt'],
      isRead: map['isRead'] ?? false,
    );
  }
}