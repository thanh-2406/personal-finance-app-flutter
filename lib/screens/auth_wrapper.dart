import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/screens/auth/login_screen.dart';
import 'package:personal_finance_app_flutter/screens/main_screen.dart';
import 'package:personal_finance_app_flutter/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final _authService = AuthService();

    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // User is logged in
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user != null) {
            // User is logged in, show the main app
            return const MainScreen();
          }
          // User is logged out, show the login screen
          return const LoginScreen();
        }
        
        // Waiting for connection
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}