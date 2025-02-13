import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_remote_datasource.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteDataSource _remoteDataSource;

  NotesRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<Note>> getNotes(String userId) {
    return _remoteDataSource.getNotes(userId);
  }

  @override
  Future<Note> getNote(String userId, String noteId) async {
    return _remoteDataSource.getNote(userId, noteId);
  }

  @override
  Future<void> saveNote(String userId, Note note) async {
    final noteModel = NoteModel.fromNote(note);
    return _remoteDataSource.saveNote(userId, noteModel);
  }

  @override
  Future<void> deleteNote(String userId, String noteId) async {
    return _remoteDataSource.deleteNote(userId, noteId);
  }

  @override
  Future<int> getNoteCount(String userId) async {
    return _remoteDataSource.getNoteCount(userId);
  }

  @override
  Future<Note> encryptNote(String userId, Note note, String password) async {
    final noteModel = NoteModel.fromNote(note);
    // Use the provided password or reuse existing one
    final encryptedNote = noteModel.encrypt(password);
    await _remoteDataSource.saveNote(userId, encryptedNote);
    return encryptedNote;
  }

  @override
  Future<Note> decryptNote(String userId, Note note, String password) async {
    final noteModel = NoteModel.fromNote(note);
    try {
      final decryptedNote = password.isEmpty 
          ? noteModel.biometricDecrypt()  // Use biometric decryption if no password provided
          : noteModel.decrypt(password);   // Use password-based decryption otherwise
      
      // Always save the decrypted note to persist password and shift
      await _remoteDataSource.saveNote(userId, decryptedNote);
      return decryptedNote;
    } catch (e) {
      if (e is ArgumentError && e.message == 'Invalid password') {
        // Update lock counter on failed password attempt
        final newLockCounter = note.lockCounter + 1;
        await updateLockCounter(userId, note.id, newLockCounter);
        throw ArgumentError('Incorrect password. ${_getLockMessage(newLockCounter)}');
      }
      rethrow;
    }
  }

  String _getLockMessage(int lockCounter) {
    switch (lockCounter) {
      case 1:
        return 'Warning! This note will be locked after 2 more failed attempts.';
      case 2:
        return 'Warning! This note will be locked after 1 more failed attempt.';
      default:
        return 'This note is now locked and can only be unlocked via TouchID or FaceID.';
    }
  }

  @override
  Future<void> updateLockCounter(
    String userId,
    String noteId,
    int lockCounter,
  ) async {
    return _remoteDataSource.updateLockCounter(userId, noteId, lockCounter);
  }
} 