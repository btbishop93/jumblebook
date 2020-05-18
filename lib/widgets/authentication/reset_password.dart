import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jumblebook/models/form.dart';
import 'package:jumblebook/models/user.dart';
import 'package:jumblebook/widgets/shared/input_form.dart';
import 'package:loading_overlay/loading_overlay.dart';

Future<String> resetPasswordPrompt(BuildContext context, User user) async {
  String _title = user != null ? 'Are you sure?' : 'Forgot password?';
  StreamController<bool> _controller = StreamController<bool>();
  bool _loading = false;

  return showDialog<String>(
    context: context,
    barrierDismissible: false, // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        void onConfirmReset() async {
          _controller.add(true);
        }

        void _updateFormData(CustomInputForm form) {
          setState(() {
            _loading = form.loading;
            if (form.success == true) {
              Navigator.of(context).pop('Okay');
            }
          });
        }

        return AlertDialog(
          buttonPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          )),
          title: Center(child: Text(_title)),
          content: LoadingOverlay(
            isLoading: _loading,
            color: Colors.grey,
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                user == null
                    ? InputForm(
                        formType: FormType.FORGOT_PASSWORD,
                        emitFormDataFunction: _updateFormData,
                        triggerValidation: _controller.stream,
                      )
                    : Column(children: <Widget>[
                        Text(
                          'An email with password reset instructions will be sent to',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${user.email}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ])
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
                        Navigator.of(context).pop('Cancel');
                      },
                    ),
                  ),
                  Expanded(
                    child: OutlineButton(
                      child: Text('Ok'),
                      onPressed: onConfirmReset,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      });
    },
  );
}
