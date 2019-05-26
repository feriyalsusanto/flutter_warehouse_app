import 'package:firebase_database/firebase_database.dart';

class Category {
  String _id;
  String _name;

  Category(this._id, this._name);

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  Category.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _name = snapshot.value['name'];
  }

  Category.fromMap(Map<String, dynamic> map, String id) {
    _id = id;
    _name = map['name'];
  }
}