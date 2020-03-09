import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jumblebook/models/note.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:jumblebook/services/db_service.dart';

import 'note/note_list.dart';
import 'note/note_view.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AuthService _authService = AuthService();
  List<Note> _myNotes = [];

  @override
  void initState() {
    getNotes();
    super.initState();
  }

  Future getNotes() async {
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      _myNotes = await DbService(user.uid).getNotes();
      _myNotes.where((note) => note.title.isNotEmpty || note.content.isNotEmpty).toList()..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print(e.toString());
    }
  }

  void _newNote() {
    setState(() {
      _myNotes.add(Note(id: UniqueKey().toString(), date: DateTime.now()));
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteView(_myNotes[_myNotes.length - 1]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/title.png',
          fit: BoxFit.contain,
          height: 36,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color.fromRGBO(245, 148, 46, 1.0)),
//        leading: IconButton(
//          icon: Icon(
//            Icons.menu,
//            color: Color.fromRGBO(245, 148, 46, 1.0),
//          ),
//          onPressed: () {},
//        ),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 100,
              child: DrawerHeader(
                child: Text(
                  'Settings',
                ),
              ),
            ),
            ListTile(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FlatButton.icon(
                    icon: Icon(Icons.exit_to_app), //`Icon` to display
                    label: Text('Log out'), //`Text` to display
                    onPressed: () async {
                      Navigator.pop(context);
                      await _authService.signOut();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 0.5, color: Colors.grey),
              ),
            ),
            child: _myNotes.length > 0 ? NoteList(_myNotes) : null,
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: FloatingActionButton(
          onPressed: _newNote,
          tooltip: 'New',
          child: Icon(Icons.add),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
