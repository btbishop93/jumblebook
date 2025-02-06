import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jumblebook/models/user.dart' as app;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService with ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // convert firebase user to jumblebook user
  app.User? _userFromFirebaseUser(firebase_auth.User? user) {
    return user != null 
        ? app.User(uid: user.uid, email: user.email, isAnonymous: user.isAnonymous) 
        : null;
  }

  // auth change user stream
  Future<app.User?> get user async {
    return _userFromFirebaseUser(_auth.currentUser);
  }

  // sign in with email/password
  Future<dynamic> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      notifyListeners();
      return _userFromFirebaseUser(result.user);
    } on PlatformException catch (err) {
      return err.code;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // sign in as guest
  Future<dynamic> signInAsGuest() async {
    try {
      final result = await _auth.signInAnonymously();
      notifyListeners();
      return _userFromFirebaseUser(result.user);
    } on PlatformException catch (err) {
      return err.code;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // sign in with Google
  Future<dynamic> signInWithGoogle() async {
    try {
      debugPrint('Starting Google Sign In...');
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      debugPrint('Google Sign In result: ${googleSignInAccount?.email}');
      
      if (googleSignInAccount == null) {
        debugPrint('User cancelled the sign in');
        return null;
      }
      
      debugPrint('Getting Google auth...');
      final GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;
      debugPrint('Got Google auth tokens');
      
      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      
      debugPrint('Signing in to Firebase...');
      final result = await _auth.signInWithCredential(credential);
      debugPrint('Firebase sign in complete');
      
      notifyListeners();
      return _userFromFirebaseUser(result.user);
    } on PlatformException catch (err) {
      debugPrint('Platform Exception during Google Sign In: ${err.code}');
      return err.code;
    } catch (e) {
      debugPrint('Error during Google Sign In: $e');
      return null;
    }
  }

  // sign in with Apple
  Future<dynamic> signInWithApple() async {
    try {
      final appleSignInAccount = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      final credential = firebase_auth.OAuthProvider('apple.com').credential(
        idToken: appleSignInAccount.identityToken,
        accessToken: appleSignInAccount.authorizationCode,
      );
      
      final result = await _auth.signInWithCredential(credential);
      notifyListeners();
      return _userFromFirebaseUser(result.user);
    } on PlatformException catch (err) {
      return err.code;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // register with email/password
  Future<dynamic> registerWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      notifyListeners();
      return _userFromFirebaseUser(result.user);
    } on PlatformException catch (err) {
      return err.code;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<dynamic> resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } on PlatformException catch (err) {
      return err.code;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  //sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
