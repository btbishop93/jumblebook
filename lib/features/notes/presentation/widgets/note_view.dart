import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import 'jumble_prompt.dart';

class NoteView extends StatefulWidget {
  final String userId;
  final Note note;
  final bool isNewNote;

  const NoteView({
    super.key,
    required this.userId,
    required this.note,
    this.isNewNote = false,
  });

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  final titleController = TextEditingController();
  final noteContentController = TextEditingController();
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  late Note _note;
  late NotesBloc _notesBloc;

  late final FocusNode titleFocusNode;
  late final FocusNode noteContentFocusNode;
  bool titleFocused = false;
  bool noteContentFocused = false;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    titleFocusNode = FocusNode();
    titleFocusNode.addListener(() {
      setState(() {
        titleFocused = titleFocusNode.hasFocus;
        if (titleFocused == false) {
          _updateTitle();
        } else {
          _updateNoteContent();
        }
      });
    });
    noteContentFocusNode = FocusNode();
    noteContentFocusNode.addListener(() {
      setState(() {
        noteContentFocused = noteContentFocusNode.hasFocus;
        if (noteContentFocused == false) {
          _updateNoteContent();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notesBloc = context.read<NotesBloc>();
    
    if (widget.isNewNote) {
      _notesBloc.add(CreateNote(
        userId: widget.userId,
        note: _note,
      ));
    } else {
      // Load the latest note state from the repository
      _notesBloc.add(LoadNote(
        userId: widget.userId,
        noteId: _note.id,
      ));
    }
    titleController.text = _note.title;
    noteContentController.text = _note.content;
  }

  @override
  void dispose() {
    noteContentFocusNode.dispose();
    titleController.dispose();
    noteContentController.dispose();
    super.dispose();
  }

  void _updateTitle() {
    final inputTitle = titleController.text;
    final updatedNote = _note.copyWith(
      title: inputTitle.isEmpty ? 'New Note' : inputTitle,
      date: DateTime.now(),
    );
    _notesBloc.add(UpdateNote(
      userId: widget.userId,
      note: updatedNote,
    ));
  }

  void _updateNoteContent() {
    noteContentFocusNode.unfocus();
    final inputContent = noteContentController.text;
    if (inputContent.isEmpty) return;
    
    final updatedNote = _note.copyWith(
      content: inputContent,
      date: DateTime.now(),
    );
    _notesBloc.add(UpdateNote(
      userId: widget.userId,
      note: updatedNote,
    ));
  }

  void _actionButtonPressed(bool editingNoteContent) {
    if (editingNoteContent) {
      _updateNoteContent();
    } else {
      if (!_note.isEncrypted) {
        // If the note has a password, reuse it
        if (_note.password.isNotEmpty) {
          _notesBloc.add(EncryptNote(
            userId: widget.userId,
            note: _note.copyWith(password: ''), // Clear hashed password before re-encrypting
            password: _note.password, // Pass the stored password for re-encryption
          ));
        } else {
          _encryptNotePrompt();
        }
      } else {
        _decryptNotePrompt();
      }
    }
  }

  Future<bool> _isBiometricAvailable() async {
    bool isAvailable = false;
    try {
      isAvailable = await _localAuthentication.isDeviceSupported();
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }

    if (!mounted) return isAvailable;

    return isAvailable;
  }

  Future<bool> _authenticateNote(bool useBiometric) async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: "Please authenticate to view your note",
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == "NotAvailable") {
        try {
          isAuthenticated = await _localAuthentication.authenticate(
            localizedReason: "Please authenticate to view your note",
            options: const AuthenticationOptions(
              useErrorDialogs: true,
              stickyAuth: true,
            ),
          );
        } catch (e) {
          debugPrint(e.toString());
          return false;
        }
      } else {
        debugPrint(e.toString());
        return false;
      }
    }

    if (!mounted) return false;

    return isAuthenticated;
  }

  void _encryptNotePrompt() async {
    final result = await jumblePrompt(
      context,
      'Jumble this note?',
      _note,
    );
    if (result.password.isNotEmpty) {
      if (!mounted) return;
      _notesBloc.add(EncryptNote(
        userId: widget.userId,
        note: _note,
        password: result.password,
      ));
    }
  }

  void _decryptNotePrompt() async {
    Prompt result = Prompt("", _note.lockCounter);
    if (await _isBiometricAvailable()) {
      if (await _authenticateNote(true)) {
        if (!mounted) return;
        _notesBloc.add(DecryptNote(
          userId: widget.userId,
          note: _note,
          password: _note.password, // Empty password triggers biometric decryption
        ));
        return;
      } else {
        result = await jumblePrompt(
          context,
          'Enter your password',
          _note,
        );
      }
    } else {
      if (await _authenticateNote(false)) {
        if (!mounted) return;
        _notesBloc.add(DecryptNote(
          userId: widget.userId,
          note: _note,
          password: '', // Empty password triggers biometric decryption
        ));
        return;
      } else {
        result = await jumblePrompt(
          context,
          'Enter your password',
          _note,
        );
      }
    }

    if (!mounted) return;
    
    if (result.password.isNotEmpty) {
      _notesBloc.add(DecryptNote(
        userId: widget.userId,
        note: _note,
        password: result.password,
      ));
    } else if (result.lockCounter > _note.lockCounter) {
      _notesBloc.add(UpdateLockCounter(
        userId: widget.userId,
        noteId: _note.id,
        lockCounter: result.lockCounter,
      ));
    }
  }

  Widget _getAppBarTitle() {
    final theme = Theme.of(context);
    return _note.title.isNotEmpty && !titleFocused
        ? GestureDetector(
            onTap: () {
              noteContentFocusNode.unfocus();
              setState(() {
                titleFocused = true;
                titleController.text = _note.title;
              });
            },
            child: Text(
              _note.title,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
          )
        : TextField(
            autofocus: true,
            focusNode: titleFocusNode,
            controller: titleController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: 'Title...',
              floatingLabelBehavior: FloatingLabelBehavior.never,
              filled: false,
              fillColor: Colors.transparent,
            ),
            onSubmitted: (_) => _updateTitle(),
          );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state is NotesLoaded) {
          final updatedNote = state.notes.firstWhere(
            (note) => note.id == _note.id,
            orElse: () => _note,
          );
          if (updatedNote != _note) {
            setState(() {
              _note = updatedNote;
              titleController.text = _note.title;
              noteContentController.text = _note.content;
            });
          }
          if (state.selectedNote?.id == _note.id) {
            setState(() {
              _note = state.selectedNote!;
              noteContentController.text = _note.content;
            });
          }
        } else if (state is NoteLoaded && state.selectedNote?.id == _note.id) {
          setState(() {
            _note = state.selectedNote!;
            noteContentController.text = _note.content;
          });
        } else if (state is NoteEncrypted && state.selectedNote?.id == _note.id) {
          setState(() {
            _note = state.selectedNote!;
            noteContentController.text = _note.content;
          });
        } else if (state is NoteDecrypted && state.selectedNote?.id == _note.id) {
          setState(() {
            _note = state.selectedNote!;
            noteContentController.text = _note.content;
          });
        } else if (state is NoteLocked && state.selectedNote?.id == _note.id) {
          setState(() {
            _note = state.selectedNote!;
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: theme.primaryColor,
            ),
            title: _getAppBarTitle(),
            actions: <Widget>[
              if (!(titleFocused ||
                  (!noteContentFocused && _note.content.isEmpty)))
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                    ),
                    onPressed: () => _actionButtonPressed(noteContentFocused),
                    child: Text(
                      noteContentFocused
                          ? "Done"
                          : _note.isEncrypted
                              ? "Unjumble"
                              : "Jumble",
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  theme.brightness == Brightness.light
                      ? 'assets/images/background.png'
                      : 'assets/images/background-dark.png',
                ),
                fit: BoxFit.fill,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextField(
                  enabled: !_note.isEncrypted,
                  controller: noteContentController,
                  focusNode: noteContentFocusNode,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  enableInteractiveSelection: true,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 