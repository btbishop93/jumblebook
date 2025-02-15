import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class UnjumbleNote {
  final NotesRepository repository;

  const UnjumbleNote(this.repository);

  Future<Note> call({
    required String userId,
    required Note note,
    required String password,
  }) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (note.id.isEmpty) {
      throw ArgumentError('Note ID cannot be empty');
    }
    if (!note.isEncrypted) {
      throw StateError('Note is not jumbled');
    }
    return repository.unjumbleNote(userId, note, password);
  }
} 