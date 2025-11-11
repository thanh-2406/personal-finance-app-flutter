import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // <-- ADDED THIS IMPORT

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., 'user-not-found', 'wrong-password')
      debugPrint(e.message); // <-- This will now work
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., 'email-already-in-use')
      debugPrint(e.message); // <-- This will now work
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // TODO: Add other methods like password reset
}