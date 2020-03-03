import 'package:flutter/material.dart';
import 'package:jumblebook/models/note.dart';

class NoteView extends StatefulWidget {
  Note note;

  NoteView(this.note);

  @override
  _NoteViewState createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  final titleController = TextEditingController();
  final noteContentController = TextEditingController();
  FocusNode titleFocusNode;
  FocusNode noteContentFocusNode;
  bool titleFocused = false;
  bool noteContentFocused = false;

  @override
  void initState() {
    super.initState();
    noteContentController.text = widget.note.content;
    titleFocusNode = FocusNode();
    titleFocusNode.addListener(() {
      setState(() {
        titleFocused = titleFocusNode.hasFocus;
        if (titleFocused == false) {
          this._updateTitle();
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
    final inputContent = noteContentController.text;
    FocusScope.of(context).unfocus();
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
      setState(() {
        if (!widget.note.isEncrypted) {
          widget.note.encrypt();
        } else {
          widget.note.decrypt();
        }
        noteContentController.text = widget.note.content;
      });
    }
  }

  Widget _getAppBarTitle() {
    return widget.note.title.isNotEmpty && !titleFocused
        ? GestureDetector(
            onTap: () {
              setState(() {
                titleController.text = widget.note.title;
                titleFocused = true;
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
              hasFloatingPlaceholder: false,
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
