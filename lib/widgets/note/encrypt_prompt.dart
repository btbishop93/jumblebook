import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jumblebook/models/form.dart';
import 'package:jumblebook/models/note.dart';
import 'package:jumblebook/widgets/shared/input_form.dart';

class Prompt {
  String password = "";
  int lockCounter = 0;

  Prompt(this.password, this.lockCounter);
}

Future<Prompt> encryptPrompt(BuildContext context, String title, Note note) async {
  StreamController<bool> _controller = StreamController<bool>();
  final isEncrypted = note.isEncrypted;
  return showDialog<Prompt>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          Prompt result = new Prompt("", note.lockCounter);

          void onConfirmAction() async {
            setState(() {
              if (result.lockCounter < 3) {
                _controller.add(true);
              } else {
                Navigator.of(context).pop(result);
              }
            });
          }

          void _updateFormData(CustomInputForm form) {
            setState(() {
              result.password = form.password;
              if (isEncrypted) {
                if (form.success == true) {
                  _controller.close();
                  Navigator.of(context).pop(result);
                } else {
                  result.lockCounter = form.lockCounter;
                  result.password = "";
                }
              } else {
                _controller.close();
                Navigator.of(context).pop(result);
              }
            });
          }

          return AlertDialog(
            buttonPadding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            )),
            title: Center(child: Text(title)),
            content: !isEncrypted
                ? InputForm(
                    formType: FormType.ENCRYPT,
                    emitFormDataFunction: _updateFormData,
                    triggerValidation: _controller.stream,
                  )
                : InputForm(
                    formType: FormType.DECRYPT,
                    emitFormDataFunction: _updateFormData,
                    formData: CustomInputForm(lockCounter: note.lockCounter, password: note.password),
                    triggerValidation: _controller.stream,
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
                          result.password = "";
                          Navigator.of(context).pop(result);
                        },
                      ),
                    ),
                    Expanded(
                      child: OutlineButton(
                        child: Text('Ok'),
                        onPressed: onConfirmAction,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
      });
}
