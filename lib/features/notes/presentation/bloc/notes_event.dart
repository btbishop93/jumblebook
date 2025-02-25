import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

final class LoadNotes extends NotesEvent {
  final String userId;

  const LoadNotes(this.userId);

  @override
  List<Object> get props => [userId];
}

final class LoadNote extends NotesEvent {
  final String userId;
  final String noteId;

  const LoadNote({
    required this.userId,
    required this.noteId,
  });

  @override
  List<Object> get props => [userId, noteId];
}

final class CreateNote extends NotesEvent {
  final String userId;
  final Note note;

  const CreateNote({
    required this.userId,
    required this.note,
  });

  @override
  List<Object> get props => [userId, note];
}

final class UpdateNote extends NotesEvent {
  final String userId;
  final Note note;

  const UpdateNote({
    required this.userId,
    required this.note,
  });

  @override
  List<Object> get props => [userId, note];
}

final class DeleteNote extends NotesEvent {
  final String userId;
  final String noteId;

  const DeleteNote({
    required this.userId,
    required this.noteId,
  });

  @override
  List<Object> get props => [userId, noteId];
}

final class JumbleNote extends NotesEvent {
  final String userId;
  final Note note;
  final String password;

  const JumbleNote({
    required this.userId,
    required this.note,
    required this.password,
  });

  @override
  List<Object> get props => [userId, note, password];
}

final class UnjumbleNote extends NotesEvent {
  final String userId;
  final Note note;
  final String password;

  const UnjumbleNote({
    required this.userId,
    required this.note,
    required this.password,
  });

  @override
  List<Object> get props => [userId, note, password];
}

final class UpdateLockCounter extends NotesEvent {
  final String userId;
  final String noteId;
  final int lockCounter;

  const UpdateLockCounter({
    required this.userId,
    required this.noteId,
    required this.lockCounter,
  });

  @override
  List<Object> get props => [userId, noteId, lockCounter];
}

final class StartListeningToNotes extends NotesEvent {
  final String userId;

  const StartListeningToNotes(this.userId);

  @override
  List<Object> get props => [userId];
}

final class StopListeningToNotes extends NotesEvent {}
