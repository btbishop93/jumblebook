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
  Future<Note> encryptNote(Note note, String password) async {
    final noteModel = NoteModel.fromNote(note).encrypt(password);
    await _remoteDataSource.saveNote(note.id, noteModel);
    return noteModel;
  }

  @override
  Future<Note> decryptNote(Note note, String password) async {
    final noteModel = NoteModel.fromNote(note).decrypt(password);
    await _remoteDataSource.saveNote(note.id, noteModel);
    return noteModel;
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