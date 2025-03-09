import '../repositories/notes_repository.dart';

class DeleteAllNotes {
  final NotesRepository repository;

  const DeleteAllNotes(this.repository);

  Future<void> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    return repository.deleteAllNotes(userId);
  }
} 