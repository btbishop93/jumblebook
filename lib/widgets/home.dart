import 'package:flutter/material.dart';
import 'package:jumblebook/models/note.dart';
import 'package:jumblebook/models/user.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:provider/provider.dart';

import 'authentication/reset_password.dart';
import 'note/note_list.dart';
import 'note/note_view.dart';

class Home extends StatefulWidget {
  final User currentUser;

  Home(this.currentUser);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void _newNote(String uid) {
    Note newNote = Note(id: UniqueKey().toString(), date: DateTime.now());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteView(newNote, uid),
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
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FlatButton.icon(
                    icon: Icon(Icons.exit_to_app), //`Icon` to display
                    label: Text('Log out'), //`Text` to display
                    onPressed: () async {
                      Navigator.pop(context);
                      await Provider.of<AuthService>(context, listen: false).signOut();
                    },
                  ),
                  FlatButton.icon(
                    icon: Icon(Icons.security), //`Icon` to display
                    label: Text('Reset password'), //`Text` to display
                    onPressed: () async {
                      Navigator.pop(context);
                      await resetPasswordPrompt(context, widget.currentUser);
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
            child: NoteList(widget.currentUser),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: FloatingActionButton(
          onPressed: () => _newNote(widget.currentUser.uid),
          tooltip: 'New',
          child: Icon(Icons.add),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
