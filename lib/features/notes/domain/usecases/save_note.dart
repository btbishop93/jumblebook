import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class SaveNote {
  final NotesRepository repository;

  const SaveNote(this.repository);

  Future<void> call({required String userId, required Note note}) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (note.id.isEmpty) {
      throw ArgumentError('Note ID cannot be empty');
    }
    return repository.saveNote(userId, note);
  }
} 