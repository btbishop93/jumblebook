import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jumblebook/models/input_form.dart';
import 'package:jumblebook/models/user.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:jumblebook/widgets/shared/custom_input_form.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:provider/provider.dart';

Future<String?> resetPasswordPrompt(BuildContext context, User? user) async {
  final title = user != null ? 'Are you sure?' : 'Forgot password?';
  bool loading = false;

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final controller = StreamController<bool>();

          void onConfirmReset() async {
            if (user != null && user.email != null) {
              await Provider.of<AuthService>(context, listen: false).resetPassword(user.email!);
              if (context.mounted) {
                Navigator.of(context).pop('Okay');
              }
            } else {
              controller.add(true);
            }
          }

          void updateFormData(InputForm form) {
            setState(() {
              loading = form.loading;
            });
            if (form.success == true) {
              loading = false;
              controller.close();
              Navigator.of(context).pop('Okay');
            }
          }

          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            title: Center(child: Text(title)),
            content: Skeletonizer(
              enabled: loading,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (user == null)
                    CustomInputForm(
                      formType: FormType.FORGOT_PASSWORD,
                      emitFormDataFunction: updateFormData,
                      triggerValidation: controller.stream,
                    )
                  else
                    Column(
                      children: <Widget>[
                        const Text(
                          'An email with password reset instructions will be sent to',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user.email ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
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
                          Navigator.of(context).pop('Cancel');
                        },
                      ),
                    ),
                    Expanded(
                      child: OutlinedButton(
                        child: const Text('Ok'),
                        onPressed: onConfirmReset,
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
}
