import 'package:flutter/material.dart';
import 'package:jumblebook/models/form.dart';
import 'package:jumblebook/widgets/shared/input_form.dart';
import 'package:loading_overlay/loading_overlay.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool loading = false;

  void _updateFormData(CustomInputForm form) {
    setState(() {
      this.loading = form.loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: LoadingOverlay(
        isLoading: loading,
        color: Colors.grey,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 0.5, color: Colors.grey),
            ),
          ),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/title.png',
                      fit: BoxFit.contain,
                      height: 54,
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    InputForm(
                      formType: FormType.REGISTER,
                      emitFormDataFunction: _updateFormData,
                    ),
                    FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      child: Text(
                        'Log in',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                      onPressed: widget.toggleView,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
