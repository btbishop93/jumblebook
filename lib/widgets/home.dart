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

  const Home(this.currentUser, {super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _canResetPassword = false;

  @override
  void initState() {
    super.initState();
    _checkResetPasswordAvailability();
  }

  void _checkResetPasswordAvailability() {
    if (!mounted) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() {
      _canResetPassword = !widget.currentUser.isAnonymous && authService.isEmailProvider;
    });
  }

  void _newNote(String uid) {
    final newNote = Note(id: UniqueKey().toString(), date: DateTime.now());
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
        iconTheme: const IconThemeData(color: Color.fromRGBO(245, 148, 46, 1.0)),
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
        width: MediaQuery.of(context).size.width * 0.8,
        backgroundColor: Colors.white,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Text(
                      'Settings',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextButton.icon(
                    icon: const Icon(Icons.exit_to_app, color: Color.fromRGBO(245, 148, 46, 1.0),), //`Icon` to display
                    label: const Text('Log out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),), //`Text` to display
                    onPressed: () async {
                      Navigator.pop(context);
                      await Provider.of<AuthService>(context, listen: false).signOut();
                    },
                  ),
                  if (_canResetPassword)
                    TextButton.icon(
                      icon: const Icon(Icons.security, color: Color.fromRGBO(245, 148, 46, 1.0),), //`Icon` to display
                      label: const Text('Reset password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),), //`Text` to display
                      onPressed: () async {
                        Navigator.pop(context);
                        await resetPasswordPrompt(context, user: widget.currentUser);
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 0.5, color: Colors.grey.shade400),
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
          child: const Icon(Icons.add),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
