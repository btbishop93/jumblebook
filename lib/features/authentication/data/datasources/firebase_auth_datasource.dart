import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
}

class FirebaseAuthDataSource implements AuthDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSource({
    firebase_auth.FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser == null
          ? null
          : UserModel.fromFirebaseUser(firebaseUser);
    });
  }

  @override
  UserModel? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    return firebaseUser == null
        ? null
        : UserModel.fromFirebaseUser(firebaseUser);
  }

  Exception _handleFirebaseAuthError(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return Exception('No user found with this email.');
        case 'wrong-password':
          return Exception('Wrong password provided.');
        case 'email-already-in-use':
          return Exception('Email is already in use.');
        case 'invalid-email':
          return Exception('Invalid email address.');
        case 'weak-password':
          return Exception('Password is too weak.');
        default:
          return Exception(error.message ?? 'Authentication error occurred.');
      }
    }
    return Exception('An unexpected error occurred.');
  }
} 