import '../repositories/notes_repository.dart';

class UpdateLockCounter {
  final NotesRepository repository;

  const UpdateLockCounter(this.repository);

  Future<void> call({
    required String userId,
    required String noteId,
    required int lockCounter,
  }) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (noteId.isEmpty) {
      throw ArgumentError('Note ID cannot be empty');
    }
    if (lockCounter < 0) {
      throw ArgumentError('Lock counter cannot be negative');
    }
    return repository.updateLockCounter(userId, noteId, lockCounter);
  }
}
