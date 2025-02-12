import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jumblebook/models/input_form.dart';
import 'package:jumblebook/models/user.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:provider/provider.dart';

Future<String?> resetPasswordPrompt(BuildContext context,
    {User? user, String? email}) async {
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
              await Provider.of<AuthService>(context, listen: false)
                  .resetPassword(user.email!);
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
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            title: Center(child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)),
            content: Skeletonizer(
              enabled: loading,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'An email with password reset instructions will be sent to',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    email ??
                        user?.email ??
                        'We couldn\'t find your email. Please try again later.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        Navigator.of(context).pop('Cancel');
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
                      onPressed: onConfirmReset,
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
}
