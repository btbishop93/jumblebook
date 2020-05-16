import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jumblebook/models/note.dart';

class DbService {
  final CollectionReference notesCollection = Firestore.instance.collection('users');
  final String uid;

  DbService(this.uid);

  Future updateNote(Note note) async {
    note.date = DateTime.now();
    return await notesCollection.document(uid).collection('notes').document(note.id).setData(note.toJson(), merge: true);
  }

  Stream<QuerySnapshot> get notes {
    return notesCollection.document(uid).collection('notes').snapshots();
  }

  Future deleteNote(String noteId) {
    return notesCollection.document(uid).collection('notes').document(noteId).delete();
  }
}
