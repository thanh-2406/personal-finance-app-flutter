import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/routes.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/widgets/custom_text_field.dart';
import 'package:personal_finance_app_flutter/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // AuthWrapper will handle navigation
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in: ${e.toString()}')),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 32),
                const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                const Text('Mật khẩu', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Mật khẩu',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        text: 'Đăng nhập',
                        onPressed: _login,
                      ),
                const SizedBox(height: 16),
                const Divider(height: 24),

                // --- THIS IS THE FIX ---
                // Change Row to Wrap to prevent overflow on small screens
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 8.0, // Add spacing if they wrap to the next line
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.forgotPassword);
                      },
                      child: const Text('Quên mật khẩu?'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.signup);
                      },
                      child: const Text('Chưa có tài khoản?'),
                    ),
                  ],
                ),
                // --- END OF FIX ---
              ],
            ),
          ),
        ),
      ),
    );
  }
}