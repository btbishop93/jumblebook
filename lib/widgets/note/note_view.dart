import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jumblebook/models/note.dart';
import 'package:jumblebook/services/db_service.dart';
import 'package:local_auth/local_auth.dart';

import 'encrypt_prompt.dart';

class NoteView extends StatefulWidget {
  final Note note;
  final String uid;

  NoteView(this.note, this.uid);

  @override
  _NoteViewState createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  final titleController = TextEditingController();
  final noteContentController = TextEditingController();
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  FocusNode titleFocusNode;
  FocusNode noteContentFocusNode;
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
          this._updateTitle();
        } else {
          this._updateNoteContent();
        }
      });
    });
    noteContentFocusNode = FocusNode();
    noteContentFocusNode.addListener(() {
      setState(() {
        noteContentFocused = noteContentFocusNode.hasFocus;
        if (noteContentFocused == false) {
          this._updateNoteContent();
        }
      });
    });
  }

  @override
  void dispose() {
    // Clean up the focus node and controllers when the note is disposed.
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

  // To check if any type of biometric authentication
  // hardware is available.
  Future<bool> _isBiometricAvailable() async {
    bool isAvailable = false;
    try {
      isAvailable = await _localAuthentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return isAvailable;

    return isAvailable;
  }

  // Process of authentication user using
  // biometrics.
  Future<bool> _authenticateNote() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticateWithBiometrics(
        localizedReason: "Please authenticate to view your note",
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return false;

    return isAuthenticated;
  }

  void _encryptNotePrompt() async {
    final Prompt result = await encryptPrompt(context, 'Set a password', widget.note);
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
    Prompt result = new Prompt("", 0);
    if (await _isBiometricAvailable()) {
      if (await _authenticateNote()) {
        setState(() {
          widget.note.lockCounter = 0;
          widget.note.decrypt();
          noteContentController.text = widget.note.content;
        });
      } else {
        result = await encryptPrompt(context, 'Enter password', widget.note);
      }
    } else {
      result = await encryptPrompt(context, 'Enter password', widget.note);
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
// TODO: if biometrics and/or password fails, delete note (max 5 tries, 2 bio, 3 password attempts)
  }

  Widget _getAppBarTitle() {
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
            ),
          )
        : TextField(
            autofocus: true,
            focusNode: titleFocusNode,
            controller: titleController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Title...',
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            onSubmitted: (_) => _updateTitle(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color.fromRGBO(253, 129, 8, 1.0),
        ),
        title: _getAppBarTitle(),
        actions: <Widget>[
          (titleFocused || (!noteContentFocused && widget.note.content.isEmpty))
              ? Text("")
              : FlatButton(
                  textColor: Color.fromRGBO(253, 129, 8, 1.0),
                  onPressed: () => _actionButtonPressed(noteContentFocused),
                  child: Text(noteContentFocused ? "Done" : "${widget.note.isEncrypted ? "Unjumble" : "Jumble"}"),
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
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            child: TextField(
              enabled: !widget.note.isEncrypted,
              controller: noteContentController,
              focusNode: noteContentFocusNode,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
