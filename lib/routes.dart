import 'package:flutter/material.dart';
import 'package:personal_finance_app_flutter/models/budget_model.dart';
import 'package:personal_finance_app_flutter/models/goal_model.dart';
import 'package:personal_finance_app_flutter/screens/auth/forgot_password_screen.dart';
import 'package:personal_finance_app_flutter/screens/auth/login_screen.dart';
import 'package:personal_finance_app_flutter/screens/auth/otp_verification_screen.dart';
import 'package:personal_finance_app_flutter/screens/auth/reset_password_screen.dart';
import 'package:personal_finance_app_flutter/screens/auth/signup_screen.dart';
import 'package:personal_finance_app_flutter/screens/auth_wrapper.dart';
import 'package:personal_finance_app_flutter/screens/budget/add_edit_budget_screen.dart';
import 'package:personal_finance_app_flutter/screens/budget/budget_screen.dart';
import 'package:personal_finance_app_flutter/screens/dashboard/home_screen.dart';
import 'package:personal_finance_app_flutter/screens/dashboard/reports_screen.dart';
// Import the new/renamed goal screens
import 'package:personal_finance_app_flutter/screens/goals/add_edit_goal_screen.dart';
import 'package:personal_finance_app_flutter/screens/goals/goal_details_screen.dart';
import 'package:personal_finance_app_flutter/screens/goals/saving_goals_list_screen.dart';
import 'package:personal_finance_app_flutter/screens/main_screen.dart';
import 'package:personal_finance_app_flutter/screens/profile/notification_screen.dart';
import 'package:personal_finance_app_flutter/screens/profile/personal_info_screen.dart';
import 'package:personal_finance_app_flutter/screens/profile/profile_screen.dart';
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

  static const String profile = '/profile';
  static const String personalInfo = '/personal_info';
  static const String notifications = '/notifications';

  static const String reports = '/reports'; 

  static const String goalsList = '/goals'; 
  // NEW/RENAMED ROUTES
  static const String addEditGoal = '/add_edit_goal';
  static const String goalDetails = '/goal_details';

  static const String transactionManagement = '/transactions'; 
  static const String categorySelect = '/category_select';
  static const String newTransaction = '/new_transaction';

  static const String budget = '/budget';
  static const String addEditBudget = '/add_edit_budget';

  // Old goal routes (we'll remove them)
  // static const String addGoal = '/add_goal';
  // static const String updateGoal = '/update_goal';


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
      
      // Profile
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case personalInfo:
        return MaterialPageRoute(builder: (_) => const PersonalInfoScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());

      // Goals (UPDATED)
      case goalsList:
        return MaterialPageRoute(builder: (_) => const SavingGoalsListScreen());
      case addEditGoal:
        // Pass the Goal object if editing, or null if adding
        final goal = settings.arguments as Goal?;
        return MaterialPageRoute(builder: (_) => AddEditGoalScreen(goal: goal));
      case goalDetails:
        // Pass the Goal object to the details screen
        final goal = settings.arguments as Goal;
        return MaterialPageRoute(builder: (_) => GoalDetailsScreen(goal: goal));

      // Reports
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());

      // Transactions
      case transactionManagement:
        return MaterialPageRoute(builder: (_) => const TransactionManagementScreen());
      case categorySelect:
        return MaterialPageRoute(builder: (_) => const CategoryScreen());
      case newTransaction:
        final args = settings.arguments as Map<String, String>;
        final category = args['category']!;
        final type = args['type']!;
        return MaterialPageRoute(
            builder: (_) => NewTransactionScreen(category: category, type: type));

      // Budget
      case budget:
        return MaterialPageRoute(builder: (_) => const BudgetScreen());
      case addEditBudget:
        final budget = settings.arguments as Budget?;
        return MaterialPageRoute(builder: (_) => AddEditBudgetScreen(budget: budget));

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