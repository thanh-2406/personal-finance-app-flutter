import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';
import 'package:personal_finance_app_flutter/widgets/custom_text_field.dart';
import 'package:personal_finance_app_flutter/widgets/primary_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // --- THIS IS THE FIX ---
      // We must use named arguments, just like in the login screen
      await _authService.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // AuthWrapper will handle navigation to the home screen
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đăng ký: ${e.toString()}')),
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
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.person_add_alt_1,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Mật khẩu',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Xác nhận mật khẩu',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        text: 'Đăng ký',
                        onPressed: _signUp,
                      ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Đã có tài khoản? Đăng nhập'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}