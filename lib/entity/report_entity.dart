import 'product_entity.dart';

class Report {
  List<ReportProduct> reportProducts;

  Report(this.reportProducts);
}

class ReportProduct {
  Product product;
  int qty;

  ReportProduct(this.product, this.qty);

  @override
  String toString() {
    return 'ReportProduct{product: $product, qty: $qty}';
  }
}