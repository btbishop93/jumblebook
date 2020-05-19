import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jumblebook/models/user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // convert firebase user to jumblebook user
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid, email: user.email) : null;
  }

  // auth change user stream
  Future<User> get user {
    return _auth.currentUser().then((user) => _userFromFirebaseUser(user));
  }

  // sign in with email/password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser fbUser = result.user;
      notifyListeners();
      return _userFromFirebaseUser(fbUser);
    } on PlatformException catch (err) {
      return err.code;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // sign in with Google
  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      FirebaseUser fbUser = (await _auth.signInWithCredential(authCredential)).user;
      notifyListeners();
      return _userFromFirebaseUser(fbUser);
    } on PlatformException catch (err) {
      return err.code;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // sign in with Apple
  Future signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleSignInAccount = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final OAuthProvider oAuthProvider = OAuthProvider(providerId: 'apple.com');
      final AuthCredential authCredential = oAuthProvider.getCredential(
        idToken: appleSignInAccount.identityToken,
        accessToken: appleSignInAccount.authorizationCode,
      );
      FirebaseUser fbUser = (await _auth.signInWithCredential(authCredential)).user;
      notifyListeners();
      return _userFromFirebaseUser(fbUser);
    } on PlatformException catch (err) {
      return err.code;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // register with email/password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser fbUser = result.user;
      notifyListeners();
      return _userFromFirebaseUser(fbUser);
    } on PlatformException catch (err) {
      // Handle err
      return err.code;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } on PlatformException catch (err) {
      // Handle err
      return err.code;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async {
    try {
      var result = await _auth.signOut();
      notifyListeners();
      return result;
    } catch (e) {
      print(e.toString());
    }
  }
}
