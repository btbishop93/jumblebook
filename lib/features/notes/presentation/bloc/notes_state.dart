import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

sealed class NotesState extends Equatable {
  final List<Note> notes;
  final Note? selectedNote;
  final String? errorMessage;
  final bool isLoading;

  const NotesState({
    this.notes = const [],
    this.selectedNote,
    this.errorMessage,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [notes, selectedNote, errorMessage, isLoading];
}

final class NotesInitial extends NotesState {
  const NotesInitial() : super();
}

final class NotesLoading extends NotesState {
  const NotesLoading({
    super.notes = const [],
    super.selectedNote,
  }) : super(isLoading: true);
}

final class NotesLoaded extends NotesState {
  const NotesLoaded(List<Note> notes, {super.selectedNote})
      : super(
          notes: notes,
        );
}

final class NoteLoaded extends NotesState {
  const NoteLoaded({
    required Note note,
    required super.notes,
  }) : super(
          selectedNote: note,
        );
}

final class NotesError extends NotesState {
  const NotesError(
    String message, {
    super.notes = const [],
    super.selectedNote,
  }) : super(errorMessage: message);
}

final class NoteDeleted extends NotesState {
  const NoteDeleted(List<Note> notes) : super(notes: notes);
}

final class NoteJumbled extends NotesState {
  const NoteJumbled({
    required Note note,
    required super.notes,
  }) : super(
          selectedNote: note,
        );
}

final class NoteUnjumbled extends NotesState {
  const NoteUnjumbled({
    required Note note,
    required super.notes,
  }) : super(
          selectedNote: note,
        );
}

final class NoteLocked extends NotesState {
  const NoteLocked({
    required Note note,
    required super.notes,
  }) : super(
          selectedNote: note,
        );
}
