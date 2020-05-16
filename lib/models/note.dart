import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Note {
  final String id;
  String title;
  String content;
  int decryptShift;
  bool isEncrypted;
  String password;
  DateTime date;
  int lockCounter;

  Note({
    @required this.id,
    this.title = "",
    this.content = "",
    this.decryptShift = 0,
    this.isEncrypted = false,
    this.lockCounter = 0,
    this.password = "",
    @required this.date,
  });

  Note.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        content = json['content'],
        decryptShift = json['decryptShift'],
        isEncrypted = json['isEncrypted'],
        lockCounter = json['lockCounter'],
        password = json['password'],
        date = (json['date'] as Timestamp).toDate();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'decryptShift': decryptShift,
        'isEncrypted': isEncrypted,
        'lockCounter': lockCounter,
        'password': password,
        'date': date,
      };

  Note.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.data['id'],
        title = snapshot.data['title'],
        content = snapshot.data['content'],
        decryptShift = snapshot.data['decryptShift'],
        isEncrypted = snapshot.data['isEncrypted'],
        lockCounter = snapshot.data['lockCounter'],
        password = snapshot.data['password'],
        date = snapshot.data['date'] != null ? (snapshot.data['date'] as Timestamp).toDate() : null;

  void encrypt() {
    this.decryptShift = Random().nextInt(255);
    StringBuffer encryptedStr = StringBuffer();
    this.content.runes.forEach((int rune) {
      var char = new String.fromCharCode(rune + this.decryptShift);
      encryptedStr.write(char);
    });
    this.content = encryptedStr.toString();
    this.isEncrypted = true;
  }

  void decrypt() {
    StringBuffer decryptedStr = StringBuffer();
    this.content.runes.forEach((int rune) {
      var char = new String.fromCharCode(rune - this.decryptShift);
      decryptedStr.write(char);
    });
    this.content = decryptedStr.toString();
    this.isEncrypted = false;
  }
}
