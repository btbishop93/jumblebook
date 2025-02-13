import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<UserModel> signInAnonymously();
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
}

class FirebaseAuthDataSource implements AuthDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSource({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

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
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return UserModel.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = firebase_auth.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      return UserModel.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  @override
  Future<UserModel> signInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      return UserModel.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
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
        case 'operation-not-allowed':
          return Exception('This authentication method is not enabled.');
        case 'user-disabled':
          return Exception('This user account has been disabled.');
        case 'requires-recent-login':
          return Exception('Please sign in again to complete this operation.');
        default:
          return Exception(error.message ?? 'Authentication error occurred.');
      }
    }
    return Exception('An unexpected error occurred.');
  }
} 