import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    // Create a simple encrypted password string
    final encryptedPassword =
        (user?.providerData.first.providerId == 'password')
            ? '••••••••'
            : '(Đăng nhập qua Google/Facebook)';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Email field (read-only)
            TextFormField(
              initialValue: user?.email ?? 'Không có email',
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Password field (dummy)
            TextFormField(
              initialValue: encryptedPassword,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            
            // Change Password Button
            if (user?.providerData.first.providerId == 'password')
              ElevatedButton(
                child: const Text('Đổi mật khẩu'),
                onPressed: () async {
                  try {
                    await AuthService().sendPasswordResetEmail(user!.email!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Đã gửi email đổi mật khẩu!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e')),
                      );
                    }
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}