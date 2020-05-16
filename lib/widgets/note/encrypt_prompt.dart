import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jumblebook/models/note.dart';

class Prompt {
  String password = "";
  int lockCounter = 0;

  Prompt(this.password, this.lockCounter);
}

Future<Prompt> encryptPrompt(BuildContext context, String title, Note note) async {
  final _formKey = GlobalKey<FormState>();
  Prompt result = new Prompt("", note.lockCounter);
  String _getWrongAttemptMessage() {
    if (result.lockCounter == 1) {
      return 'Warning! This note will be locked after 2 more failed attempts.';
    }
    if (result.lockCounter == 2) {
      return 'Warning! This note will be locked after 1 more failed attempt.';
    }
    return 'This note is now locked and can only be unlocked via TouchID or FaceID.';
  }

  return showDialog<Prompt>(
    context: context,
    barrierDismissible: false, // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return AlertDialog(
        buttonPadding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        )),
        title: Center(child: Text(title)),
        content: Form(
          key: _formKey,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              !note.isEncrypted
                  ? TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(1.0),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        ),
                      ),
                      onChanged: (val) {
                        result.password = val;
                      },
                    )
                  : Container(),
              TextFormField(
                obscureText: true,
                enabled: result.lockCounter < 3,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  errorMaxLines: 3,
                  labelText: note.isEncrypted ? 'Password' : 'Confirmation',
                  errorText: result.lockCounter > 0 ? _getWrongAttemptMessage() : null,
                  errorStyle: TextStyle(
                    color: Colors.red, // or any other color
                  ),
                  prefixIcon: Icon(Icons.lock),
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                ),
                validator: (val) {
                  if (val.isEmpty) {
                    return val.isEmpty ? 'Please enter a password.' : null;
                  }
                  if (note.isEncrypted) {
                    if (val != note.password) {
                      result.lockCounter++;
                      return _getWrongAttemptMessage();
                    } else {
                      result.password = note.password;
                      return null;
                    }
                  } else {
                    return val != result.password ? 'Passwords do not match.' : null;
                  }
                },
                onChanged: (val) {},
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Container(
            width: double.maxFinite,
            height: Theme.of(context).buttonTheme.height * 1.5,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: OutlineButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop(result);
                    },
                  ),
                ),
                Expanded(
                  child: OutlineButton(
                    child: Text('Ok'),
                    onPressed: () {
                      if (result.lockCounter < 3 && _formKey.currentState.validate()) {
                        Navigator.of(context).pop(result);
                      } else {
                        if (result.lockCounter > 3) {
                          Navigator.of(context).pop(result);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
