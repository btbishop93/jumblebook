import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jumblebook/models/note.dart';
import 'package:jumblebook/models/user.dart';

import './note_view.dart';

class NoteInfo extends StatelessWidget {
  final User currentUser;
  final Note inputNote;

  NoteInfo(this.currentUser, this.inputNote);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteView(inputNote, currentUser.uid),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.25, color: Colors.grey),
          ),
        ),
        child: Center(
          child: ListTile(
            title: Text(this.inputNote.title),
            subtitle: Text(DateFormat.yMd().format(this.inputNote.date)),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}
