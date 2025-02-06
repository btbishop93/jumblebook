import 'package:flutter/material.dart';
import 'package:jumblebook/models/input_form.dart';
import 'package:jumblebook/widgets/shared/custom_input_form.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Register extends StatefulWidget {
  final VoidCallback toggleView;

  const Register({required this.toggleView, super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool loading = false;

  void _updateFormData(InputForm form) {
    setState(() {
      loading = form.loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Skeletonizer(
          enabled: loading,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 0.5, color: Colors.grey.shade400),
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/title.png',
                        fit: BoxFit.contain,
                        height: 54,
                      ),
                      const SizedBox(height: 25),
                      CustomInputForm(
                        formType: FormType.REGISTER,
                        emitFormDataFunction: _updateFormData,
                      ),
                      TextButton(
                        onPressed: widget.toggleView,
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                        ),
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
