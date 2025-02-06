import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jumblebook/models/note.dart';
import 'package:jumblebook/models/user.dart';
import 'package:jumblebook/services/db_service.dart';

import 'note_info.dart';

class NoteList extends StatefulWidget {
  final User currentUser;

  const NoteList(this.currentUser, {super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: DbService(widget.currentUser.uid).notes,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          default:
            if (!snapshot.hasData) {
              return const Center(child: Text('No notes found'));
            }
            
            final noteList = snapshot.data!.docs
                .map((doc) => Note.fromSnapshot(doc))
                .toList()
                ..sort((a, b) => b.date.compareTo(a.date));

            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  direction: DismissDirection.endToStart,
                  key: Key(noteList[index].id),
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    color: Colors.red,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
                      child: Icon(
                        Icons.delete_sweep,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onDismissed: (direction) {
                    DbService(widget.currentUser.uid).deleteNote(noteList[index].id);
                  },
                  child: NoteInfo(widget.currentUser, noteList[index]),
                );
              },
            );
        }
      },
    );
  }
}
