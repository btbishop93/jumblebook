import 'package:flutter/material.dart';

import '../../models/note.dart';
import 'note_info.dart';

class NoteList extends StatefulWidget {
  List<Note> noteList;

  NoteList(this.noteList);

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.noteList.length,
      itemBuilder: (context, index) {
        return Dismissible(
          direction: DismissDirection.endToStart,
          key: Key(widget.noteList[index].id),
          background: Container(
            alignment: AlignmentDirectional.centerEnd,
            color: Colors.red,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
              child: Icon(
                Icons.delete_sweep,
                color: Colors.white,
              ),
            ),
          ),
          onDismissed: (direction) {
            setState(() {
              widget.noteList.removeAt(index);
            });
          },
          child: NoteInfo(widget.noteList[index]),
        );
      },
    );
  }
}
