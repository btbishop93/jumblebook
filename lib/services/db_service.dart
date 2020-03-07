import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jumblebook/models/note.dart';

class DbService {
  final CollectionReference notesCollection = Firestore.instance.collection('notes');
  final String uid;

  DbService(this.uid);

  Future updateUserData(Note note) async {
    // asd
    return await notesCollection.document(uid).setData({'${note.id}': note.toJson()}, merge: true);
  }
}
