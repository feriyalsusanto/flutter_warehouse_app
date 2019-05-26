import 'package:firebase_database/firebase_database.dart';

class Product {
  String _id;
  String _category;
  String _name;
  String _price;
  String _retailPrice;

  Product(this._id, this._category, this._name, this._price, this._retailPrice);

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get category => _category;

  set category(String value) {
    _category = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get price => _price;

  set price(String value) {
    _price = value;
  }

  String get retailPrice => _retailPrice;

  set retailPrice(String value) {
    _retailPrice = value;
  }

  Product.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _category = snapshot.value['category'];
    _name = snapshot.value['name'];
    _price = snapshot.value['price'];
    _retailPrice = snapshot.value['retail_price'];
  }

  Product.fromMap(Map<String, dynamic> map, String id) {
    _id = id;
    _category = map['category'];
    _name = map['name'];
    _price = map['price'];
    _retailPrice = map['retail_price'];
  }

  Map<String, dynamic> toMap() {
    return {
      'category': _category,
      'name': _name,
      'price': _price,
      'retail_price': _retailPrice,
    };
  }

  @override
  String toString() {
    return 'Product{_id: $_id, _category: $_category, _name: $_name, _price: $_price, _retailPrice: $_retailPrice}';
  }
}
