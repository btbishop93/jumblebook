import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:jumblebook/models/note.dart';
import 'package:jumblebook/services/db_service.dart';
import 'package:local_auth/local_auth.dart';

import 'jumble_prompt.dart';

class NoteView extends StatefulWidget {
  final Note note;
  final String uid;

  const NoteView(this.note, this.uid, {super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  final titleController = TextEditingController();
  final noteContentController = TextEditingController();
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  late final FocusNode titleFocusNode;
  late final FocusNode noteContentFocusNode;
  bool titleFocused = false;
  bool noteContentFocused = false;

  @override
  void initState() {
    super.initState();
    DbService(widget.uid).updateNote(widget.note);
    noteContentController.text = widget.note.content;
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
  void dispose() {
    DbService(widget.uid).updateNote(widget.note);
    noteContentFocusNode.dispose();
    titleController.dispose();
    noteContentController.dispose();
    super.dispose();
  }

  void _updateTitle() {
    final inputTitle = titleController.text;
    if (inputTitle.isEmpty) {
      setState(() {
        widget.note.title = "New Note";
      });
    } else {
      setState(() {
        widget.note.title = inputTitle;
        widget.note.date = DateTime.now();
      });
    }
  }

  void _updateNoteContent() {
    noteContentFocusNode.unfocus();
    final inputContent = noteContentController.text;
    if (inputContent.isEmpty) {
      return;
    }
    setState(() {
      widget.note.content = inputContent;
      widget.note.date = DateTime.now();
    });
  }

  void _actionButtonPressed(bool editingNoteContent) {
    if (editingNoteContent) {
      _updateNoteContent();
    } else {
      if (!widget.note.isEncrypted) {
        if (widget.note.password.isEmpty) {
          _encryptNotePrompt();
        } else {
          setState(() {
            widget.note.encrypt();
            noteContentController.text = widget.note.content;
          });
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
        options: AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: useBiometric,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == "NotAvailable") {
        try {
          isAuthenticated = await _localAuthentication.authenticate(
            localizedReason: "Please authenticate to view your note",
            options: AuthenticationOptions(
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
    final result = await jumblePrompt(context, 'Jumble this note?', widget.note);
    if (result.password.isNotEmpty) {
      setState(() {
        widget.note.password = result.password;
        widget.note.encrypt();
        noteContentController.text = widget.note.content;
      });
    }
    DbService(widget.uid).updateNote(widget.note);
  }

  void _decryptNotePrompt() async {
    Prompt result = Prompt("", 0);
    if (await _isBiometricAvailable()) {
      if (await _authenticateNote(true)) {
        setState(() {
          widget.note.lockCounter = 0;
          widget.note.decrypt();
          noteContentController.text = widget.note.content;
        });
      } else {
        result = await jumblePrompt(context, 'Enter your password', widget.note);
      }
    } else {
      if (await _authenticateNote(false)) {
        setState(() {
          widget.note.lockCounter = 0;
          widget.note.decrypt();
          noteContentController.text = widget.note.content;
        });
      } else {
        result = await jumblePrompt(context, 'Enter your password', widget.note);
      }
    }
    setState(() {
      widget.note.lockCounter = result.lockCounter;
    });
    if (result.password == widget.note.password) {
      setState(() {
        widget.note.lockCounter = 0;
        widget.note.decrypt();
        noteContentController.text = widget.note.content;
      });
    }
    DbService(widget.uid).updateNote(widget.note);
  }

  Widget _getAppBarTitle() {
    final theme = Theme.of(context);
    return widget.note.title.isNotEmpty && !titleFocused
        ? GestureDetector(
            onTap: () {
              noteContentFocusNode.unfocus();
              setState(() {
                titleFocused = true;
                titleController.text = widget.note.title;
              });
            },
            child: Text(
              widget.note.title,
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: theme.primaryColor,
        ),
        title: _getAppBarTitle(),
        actions: <Widget>[
          if (!(titleFocused || (!noteContentFocused && widget.note.content.isEmpty)))
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                ),
                onPressed: () => _actionButtonPressed(noteContentFocused),
                child: Text(
                  noteContentFocused ? "Done" : widget.note.isEncrypted ? "Unjumble" : "Jumble",
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: TextField(
              enabled: !widget.note.isEncrypted,
              controller: noteContentController,
              focusNode: noteContentFocusNode,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              enableInteractiveSelection: true,
              selectionControls: CupertinoTextSelectionControls(),
              contextMenuBuilder: (context, editableTextState) {
                return AdaptiveTextSelectionToolbar.editableText(
                  editableTextState: editableTextState,
                );
              },
              smartDashesType: SmartDashesType.enabled,
              smartQuotesType: SmartQuotesType.enabled,
              enableSuggestions: true,
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
  }
}
