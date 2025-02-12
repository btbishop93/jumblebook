import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

abstract class NotesRemoteDataSource {
  Stream<List<NoteModel>> getNotes(String userId);
  Future<NoteModel> getNote(String userId, String noteId);
  Future<void> saveNote(String userId, NoteModel note);
  Future<void> deleteNote(String userId, String noteId);
  Future<int> getNoteCount(String userId);
  Future<void> updateLockCounter(String userId, String noteId, int lockCounter);
}

class FirebaseNotesDataSource implements NotesRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseNotesDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _notesCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('notes');

  @override
  Stream<List<NoteModel>> getNotes(String userId) {
    return _notesCollection(userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  @override
  Future<NoteModel> getNote(String userId, String noteId) async {
    final doc = await _notesCollection(userId).doc(noteId).get();
    if (!doc.exists) {
      throw Exception('Note not found');
    }
    return NoteModel.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
  }

  @override
  Future<void> saveNote(String userId, NoteModel note) async {
    await _notesCollection(userId).doc(note.id).set(
          note.toJson(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> deleteNote(String userId, String noteId) async {
    await _notesCollection(userId).doc(noteId).delete();
  }

  @override
  Future<int> getNoteCount(String userId) async {
    final snapshot = await _notesCollection(userId).count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<void> updateLockCounter(
    String userId,
    String noteId,
    int lockCounter,
  ) async {
    await _notesCollection(userId).doc(noteId).update({
      'lockCounter': lockCounter,
    });
  }
} 