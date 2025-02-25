import '../repositories/notes_repository.dart';

class DeleteNote {
  final NotesRepository repository;

  const DeleteNote(this.repository);

  Future<void> call({required String userId, required String noteId}) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (noteId.isEmpty) {
      throw ArgumentError('Note ID cannot be empty');
    }
    return repository.deleteNote(userId, noteId);
  }
}
