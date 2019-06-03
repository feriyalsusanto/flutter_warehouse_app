class Supplier {
  String _id;
  String _name;
  String _phone;

  Supplier(this._id, this._name, this._phone);

  String get phone => _phone;

  set phone(String value) {
    _phone = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  Supplier.fromMap(Map<String, dynamic> map, String id) {
    _id = id;
    _name = map['name'];
    _phone = map['phone'];
  }

  Map<String, dynamic> toMap() {
    return {'name': _name, 'phone': _phone};
  }

  @override
  String toString() {
    return 'Supplier{_id: $_id, _name: $_name, _phone: $_phone}';
  }
}
