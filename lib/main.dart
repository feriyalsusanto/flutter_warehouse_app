import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'page/home.page.dart';
import 'page/splash.page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seafood Warehouse',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreenPage(),
    );
  }
}