import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pina_warehouse/entity/supplier_entity.dart';
import 'package:pina_warehouse/service/firebase_firestore_service.dart';

import 'detail.page.dart';

class SupplierListPage extends StatefulWidget {
  @override
  _SupplierListPageState createState() => _SupplierListPageState();
}

class _SupplierListPageState extends State<SupplierListPage>
    with SingleTickerProviderStateMixin {
  List<Supplier> suppliers;

  FirebaseFirestoreService db = new FirebaseFirestoreService();

  StreamSubscription<QuerySnapshot> supplierSub;

  @override
  void initState() {
    suppliers = List();

    supplierSub?.cancel();
    supplierSub = db.getSupplierList().listen((snapshot) {
      final List<Supplier> suppliers = snapshot.documents
          .map((documentSnapshot) => Supplier.fromMap(
              documentSnapshot.data, documentSnapshot.documentID))
          .toList();

      setState(() {
        this.suppliers = suppliers;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    supplierSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.all(8.0),
          child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return showSupplier(suppliers[index]);
              },
              itemCount: suppliers.length)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SupplierDetailPage();
          }));

          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget showSupplier(Supplier supplier) {
    var item = InkWell(
      child: new Card(
        child: new Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  supplier.name,
                  style: new TextStyle(
                      fontSize: 16.0, color: Colors.lightBlueAccent),
                ),
                new Text(
                  supplier.phone,
                  style: new TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0)),
      ),
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SupplierDetailPage(
            supplier: supplier,
          );
        }));

        setState(() {});
      },
    );

    return item;
  }
}
