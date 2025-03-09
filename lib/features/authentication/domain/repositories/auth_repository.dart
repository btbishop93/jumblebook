import '../entities/user.dart';

abstract class AuthRepository {
  // Email & Password
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> signUpWithEmailAndPassword(String email, String password);
  Future<void> resetPassword(String email);

  // Social Sign In
  Future<User> signInWithGoogle();
  Future<User> signInWithApple();

  // Anonymous
  Future<User> signInAnonymously();

  // General
  Future<void> signOut();
  Stream<User?> get authStateChanges;
  User? get currentUser;
  
  // Account Management
  Future<void> deleteAccount();
}
