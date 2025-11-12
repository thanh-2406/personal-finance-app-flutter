import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:personal_finance_app_flutter/core/app_theme.dart';
import 'package:personal_finance_app_flutter/routes.dart';
import 'package:personal_finance_app_flutter/screens/auth_wrapper.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- IMPORT THIS

Future<void> main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- THIS IS THE FIX ---
  // Load the localization data for Vietnamese
  await initializeDateFormatting('vi_VN', null);
  // --- END OF FIX ---

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Run the app
  runApp(const PersonalFinanceApp());
}

class PersonalFinanceApp extends StatelessWidget {
  const PersonalFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Finance Management',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      
      home: const AuthWrapper(),

      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}