import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class DecryptNote {
  final NotesRepository repository;

  const DecryptNote(this.repository);

  Future<Note> call({required Note note, required String password}) async {
    if (note.id.isEmpty) {
      throw ArgumentError('Note ID cannot be empty');
    }
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }
    if (!note.isEncrypted) {
      throw StateError('Note is not encrypted');
    }
    return repository.decryptNote(note, password);
  }
} 