import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/widgets/custom_text_field.dart';
import 'package:personal_finance_app_flutter/widgets/primary_button.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _authService = AuthService();
    final user = _authService.currentUser;

    final _usernameController = TextEditingController(
      text: user?.email ?? 'Not logged in'
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Image
            const Center(
              child: CircleAvatar(
                radius: 60,
                child: Icon(Icons.person, size: 60),
              ),
            ),
            const SizedBox(height: 16),
            
            // 2. Text
            Center(
              child: Text(
                user?.displayName ?? 'User',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 32),

            // 3. Form Fields
            CustomTextField(
              controller: _usernameController,
              hintText: 'Email',
              prefixIcon: Icons.email_outlined,
              readOnly: true, // Email is not typically editable
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Password (để trống nếu không đổi)',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 32),

            // 4. Button
            PrimaryButton(
              text: 'Lưu',
              onPressed: () {
                // TODO: Add profile update logic (e.g., update password)
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _authService.signOut();
                // Pop all screens until we are back at the auth wrapper
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            )
          ],
        ),
      ),
    );
  }
}