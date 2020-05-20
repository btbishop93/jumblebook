import 'package:flutter/material.dart';
import 'package:jumblebook/models/user.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:jumblebook/widgets/authentication/authenticate.dart';
import 'package:jumblebook/widgets/home.dart';
import 'package:jumblebook/widgets/shared/loading_indicator.dart';
import 'package:provider/provider.dart';

class UserContext extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: Provider.of<AuthService>(context).user,
      builder: (context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.error != null) {
            print("error");
            return Text(snapshot.error.toString());
          }
          // redirect to the proper page, pass the user into it
          return snapshot.hasData ? Home(snapshot.data) : Authenticate();
        } else {
          // show loading indicator
          return LoadingCircle();
        }
      },
    );
  }
}
