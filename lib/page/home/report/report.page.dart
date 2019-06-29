import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pina_warehouse/entity/product_entity.dart';
import 'package:pina_warehouse/entity/report_entity.dart';
import 'package:pina_warehouse/entity/stock_entity.dart';
import 'package:pina_warehouse/service/firebase_firestore_service.dart';

class HomeReportPage extends StatefulWidget {
  @override
  _HomeReportPageState createState() => _HomeReportPageState();
}

class _HomeReportPageState extends State<HomeReportPage>
    with SingleTickerProviderStateMixin {
  Report report = Report([]);
  List<Product> products;
  List<Stock> stocks;

  FirebaseFirestoreService db = new FirebaseFirestoreService();

  StreamSubscription<QuerySnapshot> productSub;
  StreamSubscription<QuerySnapshot> stockSub;

  @override
  void initState() {
    products = new List();
    stocks = new List();

    stockSub?.cancel();
    stockSub = db.getStockList().listen((QuerySnapshot snapshot) {
      final List<Stock> stocks = snapshot.documents
          .map((documentSnapshot) =>
              Stock.fromMap(documentSnapshot.data, documentSnapshot.documentID))
          .toList();

      setState(() {
        this.stocks = stocks;
      });
    });

    productSub?.cancel();
    productSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Product> products = snapshot.documents
          .map((documentSnapshot) => Product.fromMap(
              documentSnapshot.data, documentSnapshot.documentID))
          .toList();

      List<ReportProduct> reportProducts = List();
      products.forEach((product) {
        ReportProduct reportProduct;
        Stock foundStock;
        stocks.forEach((stock) {
          if (product.id == stock.productId) foundStock = stock;
        });
        if (foundStock != null) {
          reportProduct = ReportProduct(product, foundStock.qty);
        } else {
          reportProduct = ReportProduct(product, 0);
        }

        reportProducts.add(reportProduct);
      });

      setState(() {
        this.products = products;
        this.report = Report(reportProducts);
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    productSub?.cancel();
    stockSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Card(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Daftar Stock Gudang',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      ListView.builder(
                        itemBuilder: (context, index) {
                          ReportProduct product = report.reportProducts[index];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                product.product.name,
                                style: TextStyle(color: Colors.blue),
                              ),
                              Text(
                                'Stock : ${product.qty}',
                                style: TextStyle(color: Colors.blueGrey),
                              ),
                            ],
                          );
                        },
                        shrinkWrap: true,
                        itemCount: report.reportProducts.length,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
