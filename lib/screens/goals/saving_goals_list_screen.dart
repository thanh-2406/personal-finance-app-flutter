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

          goalNotificationService.checkGoalDeadlines(goals);

          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];

              return Dismissible(
                key: Key(goal.id!),
                direction: DismissDirection.endToStart,
                // --- ADDED: Confirmation Dialog ---
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Xác nhận xóa"),
                        content: Text("Bạn có chắc muốn xóa mục tiêu '${goal.name}' không?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Hủy"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
                // ----------------------------------
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
                    Navigator.pushNamed(context, AppRoutes.goalDetails,
                        arguments: goal);
                  },
                  onEdit: () {
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