import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pina_warehouse/entity/category_entity.dart';
import 'package:pina_warehouse/entity/product_entity.dart';
import 'package:pina_warehouse/service/firebase_firestore_service.dart';
import 'package:pina_warehouse/widget/multiple_select_chip.dart';

import 'detail.page.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage>
    with SingleTickerProviderStateMixin {
  List<Product> products;
  List<Product> filterProducts;
  List<Category> categories;
  List<Category> selectedCategories;

  FirebaseFirestoreService db = new FirebaseFirestoreService();

  StreamSubscription<QuerySnapshot> productSub;
  StreamSubscription<QuerySnapshot> categorySub;

  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));

    products = new List();
    filterProducts = new List();
    categories = new List();
    selectedCategories = new List();

    productSub?.cancel();
    productSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Product> products = snapshot.documents
          .map((documentSnapshot) => Product.fromMap(
              documentSnapshot.data, documentSnapshot.documentID))
          .toList();

      setState(() {
        this.products = products;
        filterProducts = products;
      });
    });

    categorySub?.cancel();
    categorySub = db.getCategoryList().listen((QuerySnapshot snapshot) {
      final List<Category> categories = snapshot.documents
          .map((documentSnapshot) => Category.fromMap(
              documentSnapshot.data, documentSnapshot.documentID))
          .toList();

      setState(() {
        this.categories = categories;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    categorySub?.cancel();
    productSub?.cancel();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: ListView.builder(
            itemBuilder: (context, index) {
              return showProduct(filterProducts[index]);
            },
            itemCount: filterProducts.length),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Transform(
            transform: Matrix4.translationValues(
              0.0,
              _translateButton.value * 2.0,
              0.0,
            ),
            child: Container(
              child: FloatingActionButton(
                heroTag: 'add',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ProductDetailPage(product: null);
                  }));
                },
                tooltip: 'Tambah Produk',
                child: Icon(Icons.add),
              ),
            ),
          ),
          Transform(
            transform: Matrix4.translationValues(
              0.0,
              _translateButton.value,
              0.0,
            ),
            child: Container(
              child: FloatingActionButton(
                heroTag: 'filter',
                onPressed: showFilterDialog,
                tooltip: 'Filter Kategori',
                child: Icon(Icons.sort),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: _buttonColor.value,
            onPressed: () async {
              animate();
            },
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animateIcon,
            ),
          ),
        ],
      ),
    );
  }

  Widget showProduct(Product product) {
    var item = InkWell(
      child: new Card(
        child: new Container(
            child: new Center(
              child: new Row(
                children: <Widget>[
                  new CircleAvatar(
                    radius: 30.0,
                    child: new Text(
                      product.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(18.0),
                          fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xFF20283e),
                  ),
                  new Expanded(
                    child: new Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            product.name,
                            style: new TextStyle(
                                fontSize: ScreenUtil().setSp(16.0),
                                color: Colors.lightBlueAccent),
                          ),
                          new Text(
                            'Rp ${product.price}',
                            style: new TextStyle(
                                fontSize: ScreenUtil().setSp(12.0),
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0)),
      ),
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductDetailPage(
            product: product,
          );
        }));

        setState(() {});
      },
    );

    return item;
  }

  showFilterDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Kategori"),
            content: MultiSelectChip(categories, selectedCategories,
                onSelectionChanged: (selectedList) {
              setState(() {
                selectedCategories = selectedList;
              });
            }),
            actions: <Widget>[
              FlatButton(
                child: Text("Filter"),
                onPressed: () {
                  onFilteredSubmit();
                  animate();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  onFilteredSubmit() {
    showLoading();
    List<Product> filters = List();
    setState(() {
      if (selectedCategories.length > 0)
        products.forEach((product) {
          selectedCategories.forEach((category) {
            if (product.category == category.id) filters.add(product);
          });
        });
      else
        filters.addAll(products);

      filterProducts = filters;
    });

    Navigator.pop(context);
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
