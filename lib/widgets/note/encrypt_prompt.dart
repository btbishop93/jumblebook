import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jumblebook/models/input_form.dart';
import 'package:jumblebook/models/note.dart';
import 'package:jumblebook/widgets/shared/custom_input_form.dart';

class Prompt {
  String password;
  int lockCounter;

  Prompt(this.password, this.lockCounter);
}

Future<Prompt> encryptPrompt(BuildContext context, String title, Note note) async {
  final controller = StreamController<bool>();
  final isEncrypted = note.isEncrypted;
  
  final result = await showDialog<Prompt>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final result = Prompt("", note.lockCounter);

          void onConfirmAction() async {
            if (note.lockCounter >= 3) {
              Navigator.of(context).pop(result);
            } else {
              controller.add(true);
            }
          }

          void updateFormData(InputForm form) {
            setState(() {
              result.password = form.password;
              if (isEncrypted) {
                if (form.success == true) {
                  controller.close();
                  Navigator.of(context).pop(result);
                } else {
                  result.lockCounter = form.lockCounter;
                  result.password = "";
                }
              } else {
                controller.close();
                Navigator.of(context).pop(result);
              }
            });
          }

          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            title: Center(child: Text(title)),
            content: !isEncrypted
                ? CustomInputForm(
                    formType: FormType.ENCRYPT,
                    emitFormDataFunction: updateFormData,
                    triggerValidation: controller.stream,
                  )
                : CustomInputForm(
                    formType: FormType.DECRYPT,
                    emitFormDataFunction: updateFormData,
                    formData: InputForm(lockCounter: note.lockCounter, password: note.password),
                    triggerValidation: controller.stream,
                  ),
            actions: <Widget>[
              SizedBox(
                width: double.maxFinite,
                height: Theme.of(context).buttonTheme.height * 1.5,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          result.password = "";
                          Navigator.of(context).pop(result);
                        },
                      ),
                    ),
                    Expanded(
                      child: OutlinedButton(
                        child: const Text('Ok'),
                        onPressed: onConfirmAction,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    },
  );
  
  return result ?? Prompt("", note.lockCounter);
}
