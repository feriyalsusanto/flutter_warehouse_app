import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pina_warehouse/service/auth_service.dart';
import 'package:pina_warehouse/widget/extended_text_field.dart';

import '../home.page.dart';

class UserPinPage extends StatefulWidget {
  UserPinPage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  _UserPinPageState createState() => _UserPinPageState();
}

class _UserPinPageState extends State<UserPinPage> {
  final String MANAGER_PIN = '1234';
  final String GENERAL_PIN = '1111';

  String _error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil.instance.setWidth(64.0),
            vertical: ScreenUtil.instance.setHeight(32.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Icon(
                Icons.android,
                size: 96.0,
                color: Colors.blue,
              ),
              margin: EdgeInsets.only(bottom: 16.0),
            ),
            ExtendedTextField(
              hintText: 'PIN',
              hintStyle: TextStyle(
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                  color: Colors.grey),
              keyboardType: TextInputType.number,
              obscureText: true,
              textAlign: TextAlign.center,
              maxLength: 4,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: ScreenUtil.instance.setSp(24.0),
                  fontWeight: FontWeight.w600),
              onChanged: (pin) {
                setState(() {
                  _error = '';
                });

                if (pin == MANAGER_PIN) {
                  _gotoHomePage();
                } else if (pin == GENERAL_PIN) {
                  _gotoHomePage();
                } else if (pin.length == 4) {
                  setState(() {
                    _error = 'PIN yang anda masukkan salah';
                  });
                }
              },
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 4.0),
              child: Text(
                _error,
                style: TextStyle(
                    color: Colors.red,
                    fontSize: ScreenUtil.instance.setSp(12.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _gotoHomePage() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return HomePage(
        userId: widget.userId,
        auth: widget.auth,
        onSignedOut: widget.onSignedOut,
      );
    }));
  }
}
