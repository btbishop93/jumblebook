import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
    super.decryptShift = 0,
    super.isEncrypted = false,
    super.lockCounter = 0,
    super.password = "",
    required super.date,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      decryptShift: json['decryptShift'] as int? ?? 0,
      isEncrypted: json['isEncrypted'] as bool? ?? false,
      lockCounter: json['lockCounter'] as int? ?? 0,
      password: json['password'] as String? ?? '',
      date: json['date'] != null 
          ? (json['date'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'decryptShift': decryptShift,
      'isEncrypted': isEncrypted,
      'lockCounter': lockCounter,
      'password': password,
      'date': Timestamp.fromDate(date),
    };
  }

  factory NoteModel.fromNote(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      decryptShift: note.decryptShift,
      isEncrypted: note.isEncrypted,
      lockCounter: note.lockCounter,
      password: note.password,
      date: note.date,
    );
  }

  NoteModel encrypt(String password) {
    if (isEncrypted) {
      throw StateError('Note is already encrypted');
    }

    final shift = Random().nextInt(255);
    final encryptedStr = StringBuffer();
    content.runes.forEach((int rune) {
      var char = String.fromCharCode(rune + shift);
      encryptedStr.write(char);
    });

    return copyWith(
      content: encryptedStr.toString(),
      decryptShift: shift,
      isEncrypted: true,
      password: password,
    ) as NoteModel;
  }

  NoteModel decrypt(String password) {
    if (!isEncrypted) {
      throw StateError('Note is not encrypted');
    }
    if (password != this.password) {
      throw ArgumentError('Invalid password');
    }

    final decryptedStr = StringBuffer();
    content.runes.forEach((int rune) {
      var char = String.fromCharCode(rune - decryptShift);
      decryptedStr.write(char);
    });

    return copyWith(
      content: decryptedStr.toString(),
      isEncrypted: false,
    ) as NoteModel;
  }

  @override
  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    int? decryptShift,
    bool? isEncrypted,
    String? password,
    DateTime? date,
    int? lockCounter,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      decryptShift: decryptShift ?? this.decryptShift,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      password: password ?? this.password,
      date: date ?? this.date,
      lockCounter: lockCounter ?? this.lockCounter,
    );
  }
} 