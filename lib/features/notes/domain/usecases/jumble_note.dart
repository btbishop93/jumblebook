import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class JumbleNote {
  final NotesRepository repository;

  const JumbleNote(this.repository);

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
    if (note.isEncrypted) {
      throw StateError('Note is already jumbled');
    }
    return repository.jumbleNote(userId, note, password);
  }
} 