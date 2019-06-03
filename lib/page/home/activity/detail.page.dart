import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:pina_warehouse/entity/activity_entity.dart';
import 'package:pina_warehouse/entity/product_entity.dart';
import 'package:pina_warehouse/entity/supplier_entity.dart';
import 'package:pina_warehouse/service/firebase_firestore_service.dart';

import 'addproduct.page.dart';

class ActivityDetailPage extends StatefulWidget {
  Activity activity;

  ActivityDetailPage({this.activity});

  @override
  _ActivityDetailPageState createState() {
    return _ActivityDetailPageState();
  }
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  GlobalKey<FormState> formKey = new GlobalKey();
  FirebaseFirestoreService db = new FirebaseFirestoreService();

  List<Product> products;
  StreamSubscription<QuerySnapshot> productSub;

  List<Supplier> suppliers;
  StreamSubscription<QuerySnapshot> supplierSub;

  TextEditingController dateController;
  Supplier supplierSelected;
  List<ActivityProduct> activityProducts = List();

  DateTime _dateTime;

  bool isDeletable = false;

  @override
  void initState() {
    isDeletable = widget.activity != null;

    _dateTime = DateTime.now();
    if (widget.activity != null) {
      _dateTime = DateTime.parse(widget.activity.date);
      activityProducts = widget.activity.product;
    }

    dateController = TextEditingController(text: parseDateTime(_dateTime));

    products = new List();
    productSub?.cancel();
    productSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Product> products = snapshot.documents
          .map((documentSnapshot) => Product.fromMap(
              documentSnapshot.data, documentSnapshot.documentID))
          .toList();

      setState(() {
        this.products = products;
      });
    });

    suppliers = new List();
    supplierSub?.cancel();
    supplierSub = db.getSupplierList().listen((QuerySnapshot snapshot) {
      final List<Supplier> suppliers = snapshot.documents
          .map((documentSnapshot) => Supplier.fromMap(
              documentSnapshot.data, documentSnapshot.documentID))
          .toList();

      setState(() {
        this.suppliers = suppliers;
        if (widget.activity != null) {
          suppliers.forEach((supplier) {
            if (supplier.id == widget.activity.supplier)
              supplierSelected = supplier;
          });
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    productSub?.cancel();
    supplierSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detil Barang Masuk'),
        actions: <Widget>[
          IconButton(
            icon: Icon(isDeletable ? Icons.delete_forever : Icons.check),
            onPressed: () async {
              if (isDeletable) {
                _showDeleteAlertDialog(context);
              } else {
                _submitActivity();
              }
            },
            iconSize: 24.0,
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  InkWell(
                    child: Card(
                      child: TextFormField(
                        controller: dateController,
                        enabled: false,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Tanggal',
                            contentPadding: EdgeInsets.all(12.0),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent))),
                        validator: (val) =>
                            val.isEmpty ? 'Silahkan Pilih Tanggal' : null,
                      ),
                    ),
                    onTap: () {
                      DatePicker.showDateTimePicker(context,
                          currentTime: _dateTime, onConfirm: (dateTime) {
                        setState(() {
                          _dateTime = dateTime;
                          dateController.text = parseDateTime(_dateTime);
                        });
                      });
                    },
                  ),
                  Card(
                    child: DropdownButtonFormField<Supplier>(
                      decoration: InputDecoration(
                          labelText: 'Supplier',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.transparent))),
                      items: List.generate(suppliers.length, (index) {
                        Supplier supplier = suppliers[index];
                        return DropdownMenuItem(
                          value: supplier,
                          child: Text(
                            supplier.name,
                          ),
                        );
                      }),
                      onChanged: (supplier) =>
                          setState(() => supplierSelected = supplier),
                      value: supplierSelected,
                      validator: (val) => supplierSelected == null
                          ? 'Silahkan Pilih Supplier'
                          : null,
                    ),
                  ),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          child: Text(
                            'Daftar Produk',
                            style:
                                TextStyle(fontSize: 13.0, color: Colors.grey),
                          ),
                          padding: EdgeInsets.only(
                              left: 14.0, right: 16.0, top: 16.0),
                        ),
                        ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            ActivityProduct product = activityProducts[index];
                            int totalPrice = product.price * product.qty;
                            return ListTile(
                              contentPadding:
                                  EdgeInsets.only(left: 14.0, right: 14.0),
                              title: Text(product.name),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('${product.qty} x ${product.price}'),
                                  Text(
                                    'Rp $totalPrice',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              trailing: widget.activity != null
                                  ? Container(
                                      width: 10.0,
                                      height: 10.0,
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                      ),
                                      iconSize: 24.0,
                                      color: Colors.red,
                                      onPressed: () {
                                        setState(() {
                                          activityProducts.removeAt(index);
                                        });
                                      }),
                            );
                          },
                          itemCount: activityProducts.length,
                          shrinkWrap: true,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: RaisedButton(
                            onPressed: widget.activity == null
                                ? () {
                                    _addProduct();
                                  }
                                : null,
                            child: Text(
                              'Tambah Produk',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.blue,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  _submitActivity() async {
    showLoading("Tambah Data. . .");
    bool result = await db.createActivity(Activity(
        null,
        supplierSelected.id,
        supplierSelected.name,
        activityProducts,
        _dateTime.toIso8601String(),
        false));
    Navigator.pop(context);
    if (result) Navigator.pop(context, true);
  }

  _showDeleteAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Permanen'),
            content: Text(
                'Apakah anda yakin ingin menghapus aktivitas ini ? (Data yang di hapus tidak dapat di kembalikan lagi)'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              FlatButton(
                onPressed: () async {
                  showLoading("Hapus Data. . .");
                  bool result = await db.deleteActivity(widget.activity);
                  Navigator.pop(context);
                  if (result) {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  }
                },
                child: Text(
                  'Hapus',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
  }

  _addProduct() async {
    Map<String, dynamic> result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddProductPage(products);
    }));
    if (activityProducts.length == 0)
      activityProducts.add(ActivityProduct.fromMap(result));
    else {
      for (int x = 0; x < activityProducts.length; x++) {
        ActivityProduct product = activityProducts[x];
        if (product.id == result['product_id']) {
          int qty = product.qty + int.parse(result['product_qty']);
          activityProducts[x].qty = qty;
          break;
        }
      }
    }
  }

  String parseDateTime(DateTime dateTime) {
    String day = dateTime.day.toString();
    if (dateTime.day < 10) day = '0${dateTime.day}';

    String month = dateTime.month.toString();
    if (dateTime.month < 10) month = '0${dateTime.month}';

    String hour = dateTime.hour.toString();
    if (dateTime.hour < 10) hour = '0${dateTime.hour}';

    String minute = dateTime.minute.toString();
    if (dateTime.minute < 10) minute = '0${dateTime.minute}';

    return '$day-$month-${dateTime.year} $hour:$minute';
  }

  void showLoading(String message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            child: Container(
              height: 64.0,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(message),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
