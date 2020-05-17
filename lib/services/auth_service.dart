import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:jumblebook/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // convert firebase user to jumblebook user
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  // sign in with email/password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser fbUser = result.user;
      return _userFromFirebaseUser(fbUser);
    } on PlatformException catch (err) {
      // Handle err
      return err.code;
    } catch (e) {
      // other types of Exceptions
    }
  }

  Future resetPassword(String password) async {
    try {
      // get user
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
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
