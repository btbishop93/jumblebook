import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../domain/usecases/usecases.dart' as usecases;
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final usecases.GetNotes _getNotes;
  final usecases.SaveNote _saveNote;
  final usecases.DeleteNote _deleteNote;
  final usecases.EncryptNote _encryptNote;
  final usecases.DecryptNote _decryptNote;
  final usecases.UpdateLockCounter _updateLockCounter;
  final NotesRepository _notesRepository;
  StreamSubscription<List<dynamic>>? _notesSubscription;

  NotesBloc({
    required usecases.GetNotes getNotes,
    required usecases.SaveNote saveNote,
    required usecases.DeleteNote deleteNote,
    required usecases.EncryptNote encryptNote,
    required usecases.DecryptNote decryptNote,
    required usecases.UpdateLockCounter updateLockCounter,
    required NotesRepository notesRepository,
  })  : _getNotes = getNotes,
        _saveNote = saveNote,
        _deleteNote = deleteNote,
        _encryptNote = encryptNote,
        _decryptNote = decryptNote,
        _updateLockCounter = updateLockCounter,
        _notesRepository = notesRepository,
        super(const NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<LoadNote>(_onLoadNote);
    on<CreateNote>(_onCreateNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<EncryptNote>(_onEncryptNote);
    on<DecryptNote>(_onDecryptNote);
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

  Future<void> _onEncryptNote(
    EncryptNote event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading(notes: state.notes));
    try {
      final encryptedNote = await _encryptNote(
        userId: event.userId,
        note: event.note,
        password: event.password,
      );
      emit(NoteEncrypted(note: encryptedNote, notes: state.notes));
    } catch (e) {
      emit(NotesError(e.toString(), notes: state.notes));
    }
  }

  Future<void> _onDecryptNote(
    DecryptNote event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading(notes: state.notes));
    try {
      final decryptedNote = await _decryptNote(
        userId: event.userId,
        note: event.note,
        password: event.password,
      );
      emit(NoteDecrypted(note: decryptedNote, notes: state.notes));
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
    _notesSubscription = _getNotes(event.userId).listen(
      (notes) => add(LoadNotes(event.userId)),
      onError: (error) => emit(NotesError(error.toString(), notes: state.notes)),
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