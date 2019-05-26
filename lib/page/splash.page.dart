import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pina_warehouse/service/auth_service.dart';

import 'auth/login_signup.page.dart';
import 'auth/user_pin.page.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  Auth auth = Auth();

  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  @override
  void initState() {
    super.initState();

    auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });

    Future.delayed(Duration(seconds: 2)).then((_) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        switch (authStatus) {
          case AuthStatus.LOGGED_IN:
            if (_userId.length > 0 && _userId != null) {
              return UserPinPage(
                userId: _userId,
                auth: auth,
                onSignedOut: _onSignedOut,
              );
            }
            break;
          case AuthStatus.NOT_DETERMINED:
          case AuthStatus.NOT_LOGGED_IN:
            return LoginSignUpPage(
              auth: auth,
              onSignedIn: _onLoggedIn,
            );
            break;
        }
      }));
    });
  }

  void _onLoggedIn() {
    auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
        authStatus = AuthStatus.LOGGED_IN;
      });
    });
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 360, height: 640)..init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil.instance.setWidth(64.0),
            vertical: ScreenUtil.instance.setHeight(32.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.android,
              size: 96.0,
              color: Colors.blue,
            ),
            Container(
              child: Text(
                'Loading. . .',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: ScreenUtil.instance.setSp(16.0)),
              ),
              margin: EdgeInsets.only(top: 16.0, bottom: 8.0),
            ),
            LinearProgressIndicator()
          ],
        ),
      ),
    );
  }
}
