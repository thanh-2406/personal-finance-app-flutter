import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/routes.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final userName = user?.displayName ?? user?.email?.split('@').first ?? "User";
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Avatar and Name
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            
            // 2. Button List
            _buildProfileButton(
              context,
              icon: Icons.person_outline,
              text: 'Hồ sơ cá nhân',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.personalInfo);
              },
            ),
            _buildProfileButton(
              context,
              icon: Icons.language_outlined,
              text: 'Ngôn ngữ',
              onTap: () {
                // TODO: Implement language switching
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng này sẽ được phát triển sau.')),
                );
              },
            ),
            _buildProfileButton(
              context,
              icon: Icons.logout,
              text: 'Đăng xuất',
              color: Colors.red,
              onTap: () async {
                await AuthService().signOut();
                // Pop all screens and go back to login
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.authWrapper, (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for the buttons
  Widget _buildProfileButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    final buttonColor = color ?? Theme.of(context).textTheme.bodyLarge?.color;
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: buttonColor),
        title: Text(
          text,
          style: TextStyle(color: buttonColor, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: buttonColor),
        onTap: onTap,
      ),
    );
  }
}