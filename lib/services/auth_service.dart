import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Get the auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- Sign In ---
  // THIS IS THE FIX: Changed to { } to use named arguments
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in error: $e');
      throw Exception(e.message); // Throw exception to be caught by the UI
    }
  }

  // --- Sign Up ---
  Future<UserCredential?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign up error: $e');
      throw Exception(e.message); // Throw exception
    }
  }

  // --- Sign Out ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- NEW FUNCTION (Fix for personal_info_screen.dart) ---
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset error: $e');
      throw Exception(e.message);
    }
  }

  // TODO: Add other methods like password reset
}