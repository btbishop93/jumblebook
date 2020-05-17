import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:jumblebook/models/user.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    }
  }

  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
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
      // other types of Exceptions
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
