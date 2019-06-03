class Stock {
  String _id;
  String _productId;
  int _qty;

  Stock(this._id, this._productId, this._qty);

  int get qty => _qty;

  set qty(int value) {
    _qty = value;
  }

  String get productId => _productId;

  set productId(String value) {
    _productId = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  Stock.fromMap(Map<String, dynamic> map, String id) {
    _id = id;
    _productId = map['product_id'];
    _qty = map['product_qty'];
  }

  Map<String, dynamic> toMap() {
    return {'product_id': _productId, 'product_qty': _qty};
  }

  @override
  String toString() {
    return 'Stock{_id: $_id, _productId: $_productId, _qty: $_qty}';
  }
}
