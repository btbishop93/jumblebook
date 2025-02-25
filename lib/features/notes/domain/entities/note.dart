import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String content;
  final int decryptShift;
  final bool isEncrypted;
  final String password;
  final DateTime date;
  final int lockCounter;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.decryptShift = 0,
    this.isEncrypted = false,
    this.lockCounter = 0,
    this.password = "",
    required this.date,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    int? decryptShift,
    bool? isEncrypted,
    String? password,
    DateTime? date,
    int? lockCounter,
  }) {
    return Note(
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

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        decryptShift,
        isEncrypted,
        password,
        date,
        lockCounter,
      ];
}
