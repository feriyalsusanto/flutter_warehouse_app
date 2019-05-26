import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pina_warehouse/entity/category_entity.dart';
import 'package:pina_warehouse/entity/product_entity.dart';
import 'package:pina_warehouse/service/firebase_firestore_service.dart';

class ProductDetailPage extends StatefulWidget {
  Product product;

  ProductDetailPage({@required this.product});

  @override
  _ProductDetailPageState createState() {
    return _ProductDetailPageState();
  }
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  GlobalKey<FormState> formKey = new GlobalKey();
  List<Category> categories;
  FirebaseFirestoreService db = new FirebaseFirestoreService();

  StreamSubscription<QuerySnapshot> categorySub;

  TextEditingController nameController;
  TextEditingController priceController;
  TextEditingController retailPriceController;

  Category categorySelected;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
        text: widget.product == null ? '' : widget.product.name);
    priceController = TextEditingController(
        text: widget.product == null ? '' : widget.product.price ?? '');
    retailPriceController = TextEditingController(
        text: widget.product == null ? '' : widget.product.retailPrice ?? '');
    isEditing = widget.product == null;

    categories = new List();

    categorySub?.cancel();
    categorySub = db.getCategoryList().listen((QuerySnapshot snapshot) {
      final List<Category> categories = snapshot.documents
          .map((documentSnapshot) => Category.fromMap(
              documentSnapshot.data, documentSnapshot.documentID))
          .toList();

      setState(() {
        if (widget.product != null)
          categories.forEach((category) {
            if (category.id == widget.product.category)
              categorySelected = category;
          });
        this.categories = categories;
      });
    });
  }

  @override
  void dispose() {
    categorySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(categorySelected.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text('Detil Produk'),
        actions: <Widget>[
          IconButton(
            icon: Icon(!isEditing ? Icons.edit : Icons.check),
            onPressed: () async {
              if (isEditing) {
                final FormState form = formKey.currentState;
                if (form.validate()) {
                  form.save();
                  showLoading();
                  if (widget.product != null) {
                    await updateData();
                  } else {
                    await createData();
                  }
                }
              } else {
                setState(() {
                  isEditing = !isEditing;
                });
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
                  Card(
                    child: DropdownButtonFormField<Category>(
                      decoration: InputDecoration(
                          labelText: 'Kategori Produk',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          enabled: isEditing,
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.transparent))),
                      items: List.generate(categories.length, (index) {
                        Category category = categories[index];
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category.name,
                          ),
                        );
                      }),
                      onChanged: (category) => !isEditing
                          ? null
                          : setState(() => categorySelected = category),
                      value: categorySelected,
                      validator: (val) => categorySelected == null
                          ? 'Silahkan Pilih Kategori'
                          : null,
                    ),
                  ),
                  Card(
                    child: TextFormField(
                      controller: nameController,
                      enabled: isEditing,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Nama Produk',
                          contentPadding: EdgeInsets.all(12.0),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.transparent))),
                      validator: (val) =>
                          val.isEmpty ? 'Silahkan Isi Nama Produk' : null,
                    ),
                  ),
                  Card(
                    child: TextFormField(
                      controller: priceController,
                      enabled: isEditing,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Harga Produk',
                          contentPadding: EdgeInsets.all(12.0),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.transparent))),
                      validator: (val) =>
                          val.isEmpty ? 'Silahkan Isi Harga Produk' : null,
                    ),
                  ),
                  Card(
                    child: TextFormField(
                      controller: retailPriceController,
                      enabled: isEditing,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Harga Retail Produk',
                          contentPadding: EdgeInsets.all(12.0),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.transparent))),
                      validator: (val) => val.isEmpty
                          ? 'Silahkan Isi Harga Retail Produk'
                          : null,
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  updateData() async {
    Product product = widget.product;
    product.category = categorySelected.id;
    product.name = nameController.text;
    product.price = priceController.text;
    product.retailPrice = retailPriceController.text;

    await db.updateProduct(widget.product.id, product);

    Navigator.pop(context);
    Navigator.pop(context, true);
  }

  createData() async {
    bool result = await db.createProduct(Product(null, categorySelected.id,
        nameController.text, priceController.text, retailPriceController.text));
    Navigator.pop(context);
    if (result) Navigator.pop(context, true);
  }

  void showLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            child: Container(
              height: ScreenUtil().setHeight(64.0),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text("Update Data. . ."),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
