import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jumblebook/models/note.dart';
import 'package:jumblebook/models/user.dart';
import 'package:jumblebook/services/db_service.dart';

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

  //sign in anonymous
  Future signInAnonymously() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email/password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser fbUser = result.user;
      await DbService(fbUser.uid)
          .updateUserData(new Note(id: '[#0ffd4]', title: 'Test Fb4', date: DateTime.now(), content: 'I love firebase4!'));
      return _userFromFirebaseUser(fbUser);
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
      await DbService(fbUser.uid)
          .updateUserData(new Note(id: UniqueKey().toString(), title: 'Test Fb', date: DateTime.now(), content: 'I love firebase!'));
      return _userFromFirebaseUser(fbUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async {
    try {
      return await await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
