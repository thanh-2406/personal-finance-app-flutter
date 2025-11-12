import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/models/goal_model.dart';
import 'package:personal_finance_app_flutter/routes.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';
import 'package:personal_finance_app_flutter/widgets/goal_card.dart';

class SavingGoalsListScreen extends StatelessWidget {
  const SavingGoalsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) {
      // Should be handled by AuthWrapper, but as a fallback
      return const Scaffold(body: Center(child: Text("Please log in.")));
    }
    final dbService = DatabaseService(userId: user.uid);

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

          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];

              // Use Dismissible for delete functionality
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
                  goal: goal, // Pass the whole goal object
                  onTap: () {
                    // Navigate to update screen, passing the goal
                    Navigator.pushNamed(context, AppRoutes.updateGoal,
                        arguments: goal);
                  },
                ),
              );
            },
          );
        },
      ),
      // The FloatingActionButton is now managed by main_screen.dart
      // No FAB here anymore
    );
  }
}