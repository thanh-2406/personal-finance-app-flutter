// =======================================================================
// screens/auth/forgot_password_screen.dart
// =======================================================================

import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/routes.dart';
import 'package:personal_finance_app_flutter/widgets/custom_text_field.dart';
import 'package:personal_finance_app_flutter/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Image Placeholder
                Icon(
                  Icons.lock_reset,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nhập email đã đăng ký của bạn để nhận mã OTP.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                
                // 2. Form Field
                CustomTextField(
                  hintText: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),

                // 3. Button
                PrimaryButton(
                  text: 'Lấy mã OTP',
                  onPressed: () {
                    // TODO: Add OTP request logic
                    Navigator.pushNamed(context, AppRoutes.otpVerification);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}