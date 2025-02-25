import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
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

  // Hash a password using SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Check if a string is likely a SHA-256 hash
  static bool isHashedPassword(String password) {
    // SHA-256 hashes are 64 characters long and contain only hex digits
    return password.length == 64 &&
        RegExp(r'^[a-fA-F0-9]+$').hasMatch(password);
  }

  // Verify if a password matches the stored hash or plain text (for backward compatibility)
  bool verifyPassword(String password) {
    final hashedInput = hashPassword(password);
    return hashedInput == this.password ||
        password == this.password; // Check both hashed and plain text
  }

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

  NoteModel jumble(String plainPassword) {
    if (isEncrypted) {
      throw StateError('Note is already encrypted');
    }

    // Only hash the password if it's not already hashed
    final passwordToUse = isHashedPassword(plainPassword)
        ? plainPassword
        : hashPassword(plainPassword);
    final shiftToUse = decryptShift > 0 ? decryptShift : Random().nextInt(255);

    final jumbledStr = StringBuffer();
    for (final rune in content.runes) {
      var char = String.fromCharCode(rune + shiftToUse);
      jumbledStr.write(char);
    }

    return copyWith(
      content: jumbledStr.toString(),
      decryptShift: shiftToUse,
      isEncrypted: true,
      password: passwordToUse,
    ) as NoteModel;
  }

  NoteModel unjumble(String plainPassword) {
    if (!isEncrypted) {
      throw StateError('Note is not encrypted');
    }

    // Verify password before decryption
    if (!verifyPassword(plainPassword)) {
      throw ArgumentError('Invalid password');
    }

    return _performUnjumble();
  }

  // Method for biometric decryption that bypasses password verification
  NoteModel biometricUnjumble() {
    if (!isEncrypted) {
      throw StateError('Note is not encrypted');
    }

    return _performUnjumble();
  }

  // Internal method to perform the actual decryption
  NoteModel _performUnjumble() {
    final unjumbledStr = StringBuffer();
    for (final rune in content.runes) {
      var char = String.fromCharCode(rune - decryptShift);
      unjumbledStr.write(char);
    }

    // Keep the password and decryptShift for reuse
    final originalPassword = password;
    final originalShift = decryptShift;

    return copyWith(
      content: unjumbledStr.toString(),
      isEncrypted: false,
      password: originalPassword, // Keep the original password
      decryptShift: originalShift, // Keep the original shift
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
