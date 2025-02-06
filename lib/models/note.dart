import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

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
    required this.id,
    this.title = "",
    this.content = "",
    this.decryptShift = 0,
    this.isEncrypted = false,
    this.lockCounter = 0,
    this.password = "",
    required this.date,
  });

  Note.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        title = json['title'] as String? ?? "",
        content = json['content'] as String? ?? "",
        decryptShift = json['decryptShift'] as int? ?? 0,
        isEncrypted = json['isEncrypted'] as bool? ?? false,
        lockCounter = json['lockCounter'] as int? ?? 0,
        password = json['password'] as String? ?? "",
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

  Note.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.data()?['id'] as String? ?? '',
        title = snapshot.data()?['title'] as String? ?? '',
        content = snapshot.data()?['content'] as String? ?? '',
        decryptShift = snapshot.data()?['decryptShift'] as int? ?? 0,
        isEncrypted = snapshot.data()?['isEncrypted'] as bool? ?? false,
        lockCounter = snapshot.data()?['lockCounter'] as int? ?? 0,
        password = snapshot.data()?['password'] as String? ?? '',
        date = snapshot.data()?['date'] != null 
            ? (snapshot.data()?['date'] as Timestamp).toDate() 
            : DateTime.now();

  void encrypt() {
    decryptShift = Random().nextInt(255);
    final encryptedStr = StringBuffer();
    content.runes.forEach((int rune) {
      var char = String.fromCharCode(rune + decryptShift);
      encryptedStr.write(char);
    });
    content = encryptedStr.toString();
    isEncrypted = true;
  }

  void decrypt() {
    final decryptedStr = StringBuffer();
    content.runes.forEach((int rune) {
      var char = String.fromCharCode(rune - decryptShift);
      decryptedStr.write(char);
    });
    content = decryptedStr.toString();
    isEncrypted = false;
  }
}
