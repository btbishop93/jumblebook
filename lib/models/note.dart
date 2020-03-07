import 'dart:math';

import 'package:flutter/cupertino.dart';

class Note {
  final String id;
  String title;
  String content;
  int decryptShift;
  bool isEncrypted;
  var password;
  DateTime date;

  Note({
    @required this.id,
    this.title = "",
    this.content = "",
    this.decryptShift,
    this.isEncrypted = false,
    this.password,
    @required this.date,
  });

  Note.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        content = json['content'],
        decryptShift = json['decryptShift'],
        isEncrypted = json['isEncrypted'],
        password = json['password'],
        date = json['date'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'decryptShift': decryptShift,
        'isEncrypted': isEncrypted,
        'password': password,
        'date': date,
      };

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
