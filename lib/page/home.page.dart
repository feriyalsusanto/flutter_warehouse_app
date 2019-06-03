import 'package:flutter/material.dart';
import 'package:pina_warehouse/service/auth_service.dart';

import 'home/activity/list.page.dart';
import 'home/product/list.page.dart';
import 'home/report/report.page.dart';
import 'home/supplier/list.page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  List<Widget> _widgets = [
    HomeReportPage(),
    ProductListPage(),
    ActivityListPage(),
    SupplierListPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GUDANG SEAFOOD'),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.home,
                  size: 28.0,
                ),
                disabledColor: Colors.blue,
                color: Colors.grey[400],
                onPressed: _currentIndex == 0
                    ? null
                    : () => setState(() => _currentIndex = 0)),
            IconButton(
                icon: Icon(
                  Icons.view_list,
                  size: 28.0,
                ),
                disabledColor: Colors.blue,
                color: Colors.grey[400],
                onPressed: _currentIndex == 1
                    ? null
                    : () => setState(() => _currentIndex = 1)),
            IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  size: 28.0,
                ),
                disabledColor: Colors.blue,
                color: Colors.grey[400],
                onPressed: _currentIndex == 2
                    ? null
                    : () => setState(() => _currentIndex = 2)),
            IconButton(
                icon: Icon(
                  Icons.directions_bus,
                  size: 28.0,
                ),
                disabledColor: Colors.blue,
                color: Colors.grey[400],
                onPressed: _currentIndex == 3
                    ? null
                    : () => setState(() => _currentIndex = 3)),
          ],
        ),
      ),
      body: _widgets[_currentIndex],
    );
  }
}
