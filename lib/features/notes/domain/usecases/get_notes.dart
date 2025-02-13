import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class GetNotes {
  final NotesRepository repository;

  const GetNotes(this.repository);

  Stream<List<Note>> call(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    return repository.getNotes(userId);
  }
} 