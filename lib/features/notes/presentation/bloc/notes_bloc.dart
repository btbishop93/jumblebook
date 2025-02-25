import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../domain/usecases/usecases.dart' as usecases;
import '../../domain/entities/note.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final usecases.GetNotes _getNotes;
  final usecases.SaveNote _saveNote;
  final usecases.DeleteNote _deleteNote;
  final usecases.JumbleNote _jumbleNote;
  final usecases.UnjumbleNote _unjumbleNote;
  final usecases.UpdateLockCounter _updateLockCounter;
  final NotesRepository _notesRepository;
  StreamSubscription<List<dynamic>>? _notesSubscription;

  NotesBloc({
    required usecases.GetNotes getNotes,
    required usecases.SaveNote saveNote,
    required usecases.DeleteNote deleteNote,
    required usecases.JumbleNote jumbleNote,
    required usecases.UnjumbleNote unjumbleNote,
    required usecases.UpdateLockCounter updateLockCounter,
    required NotesRepository notesRepository,
  })  : _getNotes = getNotes,
        _saveNote = saveNote,
        _deleteNote = deleteNote,
        _jumbleNote = jumbleNote,
        _unjumbleNote = unjumbleNote,
        _updateLockCounter = updateLockCounter,
        _notesRepository = notesRepository,
        super(const NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<LoadNote>(_onLoadNote);
    on<CreateNote>(_onCreateNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<JumbleNote>(_onJumbleNote);
    on<UnjumbleNote>(_onUnjumbleNote);
    on<UpdateLockCounter>(_onUpdateLockCounter);
    on<StartListeningToNotes>(_onStartListeningToNotes);
    on<StopListeningToNotes>(_onStopListeningToNotes);
  }

  Future<void> _onLoadNotes(
    LoadNotes event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading(notes: state.notes));
    try {
      final notes = await _notesRepository.getNotes(event.userId).first;
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError(e.toString(), notes: state.notes));
    }
  }

  Future<void> _onLoadNote(
    LoadNote event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading(notes: state.notes));
    try {
      final note = await _notesRepository.getNote(event.userId, event.noteId);
      emit(NoteLoaded(note: note, notes: state.notes));
    } catch (e) {
      emit(NotesError(e.toString(), notes: state.notes));
    }
  }

  Future<void> _onCreateNote(
    CreateNote event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading(notes: state.notes));
    try {
      await _saveNote(userId: event.userId, note: event.note);
      final notes = await _notesRepository.getNotes(event.userId).first;
      emit(NotesLoaded(notes, selectedNote: event.note));
    } catch (e) {
      emit(NotesError(e.toString(), notes: state.notes));
    }
  }

  Future<void> _onUpdateNote(
    UpdateNote event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading(notes: state.notes));
    try {
      await _saveNote(userId: event.userId, note: event.note);
      final notes = await _notesRepository.getNotes(event.userId).first;
      emit(NotesLoaded(notes, selectedNote: event.note));
    } catch (e) {
      emit(NotesError(e.toString(), notes: state.notes));
    }
  }

  Future<void> _onDeleteNote(
    DeleteNote event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading(notes: state.notes));
    try {
      await _deleteNote(userId: event.userId, noteId: event.noteId);
      final notes = await _notesRepository.getNotes(event.userId).first;
      emit(NoteDeleted(notes));
    } catch (e) {
      emit(NotesError(e.toString(), notes: state.notes));
    }
  }

  Future<void> _onJumbleNote(
    JumbleNote event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading(notes: state.notes));
    try {
      final jumbledNote = await _jumbleNote(
        userId: event.userId,
        note: event.note,
        password: event.password,
      );
      emit(NoteJumbled(note: jumbledNote, notes: state.notes));
    } catch (e) {
      emit(NotesError(e.toString(), notes: state.notes));
    }
  }

  Future<void> _onUnjumbleNote(
    UnjumbleNote event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading(notes: state.notes));
    try {
      final unjumbledNote = await _unjumbleNote(
        userId: event.userId,
        note: event.note,
        password: event.password,
      );
      emit(NoteUnjumbled(note: unjumbledNote, notes: state.notes));
    } catch (e) {
      emit(NotesError(e.toString(), notes: state.notes));
    }
  }

  Future<void> _onUpdateLockCounter(
    UpdateLockCounter event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _updateLockCounter(
        userId: event.userId,
        noteId: event.noteId,
        lockCounter: event.lockCounter,
      );
      final note = await _notesRepository.getNote(event.userId, event.noteId);
      emit(NoteLocked(note: note, notes: state.notes));
    } catch (e) {
      emit(NotesError(e.toString(), notes: state.notes));
    }
  }

  Future<void> _onStartListeningToNotes(
    StartListeningToNotes event,
    Emitter<NotesState> emit,
  ) async {
    await _notesSubscription?.cancel();

    emit(NotesLoading(notes: state.notes));

    await emit.forEach<List<dynamic>>(
      _getNotes(event.userId),
      onData: (notes) => NotesLoaded(notes.cast<Note>()),
      onError: (error, stackTrace) {
        emit(NotesError(error.toString(), notes: state.notes));
        return state;
      },
    );
  }

  Future<void> _onStopListeningToNotes(
    StopListeningToNotes event,
    Emitter<NotesState> emit,
  ) async {
    await _notesSubscription?.cancel();
    _notesSubscription = null;
  }

  @override
  Future<void> close() async {
    await _notesSubscription?.cancel();
    return super.close();
  }
}
