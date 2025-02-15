import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../../domain/entities/note.dart';
import 'note_view.dart';

class NoteInfo extends StatelessWidget {
  final String userId;
  final Note note;

  const NoteInfo({
    super.key,
    required this.userId,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider<NotesBloc>.value(
              value: context.read<NotesBloc>(),
              child: NoteView(
                userId: userId,
                note: note,
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 0.25,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: Center(
          child: Material(
            type: MaterialType.transparency,
            child: ListTile(
              title: Text(note.title.isEmpty ? 'New Note' : note.title),
              subtitle: Text(DateFormat.yMd().format(note.date)),
              trailing: const Icon(Icons.chevron_right, size: 32),
            ),
          ),
        ),
      ),
    );
  }
} 