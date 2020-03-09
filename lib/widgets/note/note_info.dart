import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jumblebook/models/note.dart';
import 'package:jumblebook/models/user.dart';
import 'package:provider/provider.dart';

import './note_view.dart';

class NoteInfo extends StatelessWidget {
  final Note inputNote;

  NoteInfo(this.inputNote);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteView(inputNote, user.uid),
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
