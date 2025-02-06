import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jumblebook/models/note.dart';

class DbService {
  final CollectionReference<Map<String, dynamic>> notesCollection = 
      FirebaseFirestore.instance.collection('users');
  final String uid;

  DbService(this.uid);

  Future<void> updateNote(Note note) async {
    return await notesCollection
        .doc(uid)
        .collection('notes')
        .doc(note.id)
        .set(note.toJson(), SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get notes {
    return notesCollection
        .doc(uid)
        .collection('notes')
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) => snapshot.data()!,
          toFirestore: (data, _) => data,
        )
        .snapshots();
  }

  Future<void> deleteNote(String noteId) {
    return notesCollection
        .doc(uid)
        .collection('notes')
        .doc(noteId)
        .delete();
  }
}
