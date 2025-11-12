import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app_flutter/models/notification_model.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/services/database_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in.")));
    }
    final dbService = DatabaseService(userId: user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: dbService.getNotificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có thông báo nào.'));
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final isWarning = notif.type == NotificationType.warning;
              final icon = isWarning ? Icons.warning_amber : Icons.error;
              final color = isWarning ? Colors.orange : Colors.red;

              return Card(
                elevation: 0,
                color: notif.isRead ? Colors.white : color.withOpacity(0.05),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Icon(icon, color: color),
                  title: Text(
                    notif.title,
                    style: TextStyle(
                        fontWeight:
                            notif.isRead ? FontWeight.normal : FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notif.body),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy, hh:mm a', 'vi_VN')
                            .format(notif.createdAt.toDate()),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // Mark as read when tapped
                    if (!notif.isRead) {
                      dbService.markNotificationAsRead(notif.id);
                    }
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