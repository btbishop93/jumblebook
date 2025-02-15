import '../entities/note.dart';

abstract class NotesRepository {
  /// Get a stream of all notes for a user
  Stream<List<Note>> getNotes(String userId);

  /// Get a specific note by ID
  Future<Note> getNote(String userId, String noteId);

  /// Create or update a note
  Future<void> saveNote(String userId, Note note);

  /// Delete a note
  Future<void> deleteNote(String userId, String noteId);

  /// Get the total count of notes for a user
  Future<int> getNoteCount(String userId);

  /// Jumble a note's content
  Future<Note> jumbleNote(String userId, Note note, String password);

  /// Unjumble a note's content
  Future<Note> unjumbleNote(String userId, Note note, String password);

  /// Update note's lock counter
  Future<void> updateLockCounter(String userId, String noteId, int lockCounter);
} 