import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/models/goal_model.dart';
import 'package:personal_finance_app_flutter/routes.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:personal_finance_app_flutter/services/goal_notification_service.dart';
import 'package:personal_finance_app_flutter/widgets/goal_card.dart';

class SavingGoalsListScreen extends StatelessWidget {
  const SavingGoalsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in.")));
    }
    final dbService = DatabaseService(userId: user.uid);
    // Initialize the new notification service
    final goalNotificationService = GoalNotificationService(dbService: dbService);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mục tiêu tài chính'),
      ),
      body: StreamBuilder<List<Goal>>(
        stream: dbService.getGoalsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child:
                    Text('Bạn chưa có mục tiêu nào. Hãy thêm một mục tiêu!'));
          }

          final goals = snapshot.data!;

          // --- RUN NOTIFICATION CHECK ---
          // When the goals are loaded, check for deadlines
          goalNotificationService.checkGoalDeadlines(goals);
          // --- END OF CHECK ---

          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];

              return Dismissible(
                key: Key(goal.id!),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  dbService.deleteGoal(goal.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã xoá mục tiêu "${goal.name}"')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: GoalCard(
                  goal: goal,
                  onTap: () {
                    // --- UPDATED NAVIGATION ---
                    // Navigate to the new GoalDetailsScreen
                    Navigator.pushNamed(context, AppRoutes.goalDetails,
                        arguments: goal);
                  },
                  onEdit: () {
                    // --- NEW EDIT FUNCTION ---
                    // Navigate to the AddEditGoalScreen to edit
                    Navigator.pushNamed(context, AppRoutes.addEditGoal,
                        arguments: goal);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}