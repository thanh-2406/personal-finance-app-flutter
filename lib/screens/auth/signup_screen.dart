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
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // The AuthWrapper will handle navigation
      if (mounted) Navigator.pop(context); // Go back to login
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign up: ${e.toString()}')),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
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
            child: Form(
              key: _formKey,
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
                    validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: 'Username',
                    prefixIcon: Icons.person_outline,
                    // Note: Firebase auth doesn't use username by default
                    // You would save this to a 'users' collection in Firestore
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (val) => val != _passwordController.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 24),
                  
                  PrimaryButton(
                    onPressed: _isLoading ? null : _signUp,
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Đăng ký'),
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
      ),
    );
  }
}