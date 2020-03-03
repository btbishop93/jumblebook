import 'package:flutter/material.dart';
import 'package:jumblebook/models/user.dart';
import 'package:jumblebook/widgets/authentication/authenticate.dart';
import 'package:jumblebook/widgets/home_page.dart';
import 'package:provider/provider.dart';

class UserContext extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if (user != null) {
      return MyHomePage();
    } else {
      return Authenticate();
    }
  }
}
