import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_finance_app_flutter/models/goal_model.dart';
import 'package:personal_finance_app_flutter/models/notification_model.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:uuid/uuid.dart';

class GoalNotificationService {
  final DatabaseService dbService;
  GoalNotificationService({required this.dbService});

  Future<void> checkGoalDeadlines(List<Goal> goals) async {
    if (goals.isEmpty) return;

    final now = DateTime.now();
    final oneWeekFromNow = now.add(const Duration(days: 7));

    for (final goal in goals) {
      // Skip if no deadline or if already completed
      if (goal.deadline == null || goal.currentAmount >= goal.targetAmount) {
        continue;
      }

      final deadline = goal.deadline!.toDate();

      // Check if the deadline is between now and 1 week from now
      if (deadline.isAfter(now) && deadline.isBefore(oneWeekFromNow)) {
        
        final daysLeft = deadline.difference(now).inDays;
        final String dayString = daysLeft > 1 ? '$daysLeft ngày' : '1 ngày';

        final notification = AppNotification(
          id: const Uuid().v4(), // Generate a unique ID
          title: "Sắp đến hạn mục tiêu!",
          body:
              "Mục tiêu '${goal.name}' của bạn sắp đến hạn trong $dayString. Cố lên!",
          type: NotificationType.warning,
          createdAt: Timestamp.now(),
        );
        
        // Add to database. The DB service will handle duplicates
        await dbService.addNotification(notification);
      }
    }
  }
}