import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jumblebook/models/note.dart';

class DbService {
  final CollectionReference notesCollection = Firestore.instance.collection('notes');
  final String uid;

  List<Note> notes = [];

  DbService(this.uid);

  Future updateNote(Note note) async {
    return await notesCollection.document(uid).setData({'${note.id}': note.toJson()}, merge: true);
  }

  Future getNotes() async {
    var fbNotes = await notesCollection.document(uid).get();
    fbNotes.data.forEach((key, val) => {notes.add(Note.fromJson(val))});
    return notes;
  }
}
