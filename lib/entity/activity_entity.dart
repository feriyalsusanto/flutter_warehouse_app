import 'dart:convert';

class Activity {
  String _id;
  String _supplier;
  String _supplierName;
  List<ActivityProduct> _product;
  String _date;
  bool _isOut;

  Activity(this._id, this._supplier, this._supplierName, this._product,
      this._date, this._isOut);

  bool get isOut => _isOut;

  set isOut(bool value) {
    _isOut = value;
  }

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  List<ActivityProduct> get product => _product;

  set product(List<ActivityProduct> value) {
    _product = value;
  }

  String get supplier => _supplier;

  set supplier(String value) {
    _supplier = value;
  }

  String get supplierName => _supplierName;

  set supplierName(String value) {
    _supplierName = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  Activity.fromMap(Map<String, dynamic> map, String id) {
    _id = id;
    _supplier = map['supplier'];
    _supplierName = map['supplier_name'];
    _date = map['date'];
    _isOut = map['status'];

    List<ActivityProduct> products = List();
    (map['product'] as List).map((map) {
      print(map);
      products.add(ActivityProduct(
          id: map["product_id"],
          name: map["product_name"],
          price: map["product_price"],
          qty: map["product_qty"]));
    }).toList();
    _product = products;
  }

  Activity.fromOutMap(Map<String, dynamic> map, String id) {
    _id = id;
    _date = map['date'];
    _isOut = map['status'];

    List<ActivityProduct> products = List();
    (map['product'] as List).map((map) {
      Map<dynamic, dynamic> json = map;
      products.add(ActivityProduct(
          id: json['productid'] == null ? json['product_id'] : json['productid'],
          name: json["productname"] == null ? json["product_name"] : json["productname"],
          price: json["productprice"] == null ? json["product_price"] : json["productprice"],
          qty: json["productqty"] == null ? json["product_qty"] : json["productqty"]));
    }).toList();
    _product = products;
  }

  List encondeToJson(List<ActivityProduct> list) {
    List jsonList = List();
    list.map((item) => jsonList.add(item.toJson())).toList();
    return jsonList;
  }

  Map<String, dynamic> toMap() {
    return {
      'supplier': _supplier,
      'supplier_name': _supplierName,
      'product': encondeToJson(_product),
      'date': _date,
      'status': _isOut
    };
  }

  @override
  String toString() {
    return 'Activity{_id: $_id, _supplier: $_supplier, _supplierName: $_supplierName, _product: $_product, _date: $_date, _isOut: $_isOut}';
  }
}

class ActivityProduct {
  String id;
  String name;
  int qty;
  int price;

  ActivityProduct({this.id, this.name, this.qty, this.price});

  ActivityProduct.fromMap(Map<String, dynamic> map) {
    id = map['product_id'];
    name = map['product_name'];
    qty = int.parse(map['product_qty'].toString());
    price = int.parse(map['product_price'].toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': id,
      'product_name': name,
      'product_price': price,
      'product_qty': qty
    };
  }

  @override
  String toString() {
    return 'ActivityProduct{id: $id, name: $name, qty: $qty, price: $price}';
  }
}
