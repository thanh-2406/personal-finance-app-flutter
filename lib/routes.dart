import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/models/goal_model.dart';
import 'package:personal_finance_app_flutter/models/transaction_model.dart'; // Make sure this is imported
import 'package:personal_finance_app_flutter/screens/auth/edit_profile_screen.dart';
import 'package:personal_finance_app_flutter/screens/auth/forgot_password_screen.dart';
import 'package:personal_finance_app_flutter/screens/auth/login_screen.dart';
import 'package:personal_finance_app_flutter/screens/auth/otp_verification_screen.dart';
import 'package:personal_finance_app_flutter/screens/auth/reset_password_screen.dart';
import 'package:personal_finance_app_flutter/screens/auth/signup_screen.dart';
import 'package:personal_finance_app_flutter/screens/auth_wrapper.dart';
import 'package:personal_finance_app_flutter/screens/budget/budget_config_screen.dart';
import 'package:personal_finance_app_flutter/screens/budget/budget_history_screen.dart';
import 'package:personal_finance_app_flutter/screens/dashboard/home_screen.dart';
import 'package:personal_finance_app_flutter/screens/dashboard/reports_screen.dart';
import 'package:personal_finance_app_flutter/screens/goals/add_goal_screen.dart';
import 'package:personal_finance_app_flutter/screens/goals/saving_goals_list_screen.dart';
import 'package:personal_finance_app_flutter/screens/goals/update_progress_screen.dart';
import 'package:personal_finance_app_flutter/screens/main_screen.dart';
import 'package:personal_finance_app_flutter/screens/transactions/category_screen.dart';
import 'package:personal_finance_app_flutter/screens/transactions/new_transaction_screen.dart';
import 'package:personal_finance_app_flutter/screens/transactions/transaction_management_screen.dart';

class AppRoutes {
  // Route Names
  static const String authWrapper = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot_password';
  static const String otpVerification = '/otp';
  static const String resetPassword = '/reset_password';
  
  static const String main = '/main';
  static const String home = '/home';
  static const String editProfile = '/edit_profile';

  static const String reports = '/reports'; 

  static const String goalsList = '/goals';
  static const String addGoal = '/add_goal';
  static const String updateGoal = '/update_goal';

  static const String transactionManagement = '/transactions';
  static const String categorySelect = '/category_select';
  static const String newTransaction = '/new_transaction';

  static const String budgetConfig = '/budget_config';
  static const String budgetHistory = '/budget_history';

  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth
      case authWrapper:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case otpVerification:
        return MaterialPageRoute(builder: (_) => const OtpVerificationScreen());
      case resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());

      // Main App
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      
      // Goals
      case goalsList:
        return MaterialPageRoute(builder: (_) => const SavingGoalsListScreen());
      case addGoal:
        return MaterialPageRoute(builder: (_) => const AddNewGoalScreen());
      case updateGoal:
        final goal = settings.arguments as Goal;
        return MaterialPageRoute(builder: (_) => UpdateProgressScreen(goal: goal));

      // Reports
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());

      // Transactions
      case transactionManagement:
        return MaterialPageRoute(builder: (_) => const TransactionManagementScreen());
      case categorySelect:
        return MaterialPageRoute(builder: (_) => const CategoryScreen());
      case newTransaction:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => NewTransactionScreen(
            category: args['category'] as String,
            // VVV THIS IS THE FIX VVV
            type: args['type'] as TransactionType, 
            // ^^^ THIS IS THE FIX ^^^
          ),
        );

      // Budget
      case budgetConfig:
        return MaterialPageRoute(builder: (_) => const BudgetConfigurationScreen());
      case budgetHistory:
        return MaterialPageRoute(builder: (_) => const BudgetReminderHistoryScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}