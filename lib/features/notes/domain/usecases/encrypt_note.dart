import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class EncryptNote {
  final NotesRepository repository;

  const EncryptNote(this.repository);

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
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }
    if (note.isEncrypted) {
      throw StateError('Note is already encrypted');
    }
    return repository.encryptNote(userId, note, password);
  }
} 