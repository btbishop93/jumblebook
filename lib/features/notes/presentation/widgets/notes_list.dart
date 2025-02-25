import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import 'note_info.dart';

class NotesList extends StatelessWidget {
  final String userId;

  const NotesList({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesBloc, NotesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.notes.isEmpty) {
          return const Center(child: Text('No notes found'));
        }

        final notes = List<Note>.from(state.notes)
          ..sort((a, b) => b.date.compareTo(a.date));

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return Dismissible(
              direction: DismissDirection.endToStart,
              key: Key(notes[index].id),
              background: Container(
                alignment: AlignmentDirectional.centerEnd,
                color: Colors.red,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
                  child: Icon(
                    Icons.delete_sweep,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              onDismissed: (direction) {
                context.read<NotesBloc>().add(DeleteNote(
                      userId: userId,
                      noteId: notes[index].id,
                    ));
              },
              child: NoteInfo(
                userId: userId,
                note: notes[index],
              ),
            );
          },
        );
      },
    );
  }
}
