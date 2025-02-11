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

Future<Prompt> jumblePrompt(BuildContext context, String title, Note note) async {
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            title: Center(child: Text(title, style: const TextStyle(fontSize: 18),)),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  !isEncrypted
                      ? const Text(
                    'Create a password. You will need your password or biometric authentication to Unjumble this note.',
                    style: TextStyle(fontSize: 12),
                  )
                  : const Text(
                    'To unjumble this note, enter your password.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  !isEncrypted
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
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                          result.password = "";
                          Navigator.of(context).pop(result);
                        },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirmAction,
                      style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                      child: Text(
                        'Send',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
  
  return result ?? Prompt("", note.lockCounter);
}
