import 'package:flutter/material.dart';
import 'package:pina_warehouse/entity/product_entity.dart';

class AddProductPage extends StatefulWidget {
  final List<Product> products;
  final Product product;

  AddProductPage(this.products, {this.product});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  GlobalKey<FormState> formKey = new GlobalKey();
  Product productSelected;

  TextEditingController priceController;
  TextEditingController qtyController = TextEditingController();

  Map<String, dynamic> mResult;

  @override
  void initState() {
    if (widget.product != null) productSelected = widget.product;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Produk'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              final FormState form = formKey.currentState;
              if (form.validate()) {
                form.save();
                showLoading();
                mResult = {
                  'product_id': productSelected.id,
                  'product_name': productSelected.name,
                  'product_price': productSelected.retailPrice,
                  'product_qty': qtyController.text
                };
                Navigator.pop(context);
                Navigator.pop(context, mResult);
              }
            },
            iconSize: 24.0,
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  Card(
                    child: DropdownButtonFormField<Product>(
                      decoration: InputDecoration(
                          labelText: 'Produk',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.transparent))),
                      items: List.generate(widget.products.length, (index) {
                        Product product = widget.products[index];
                        return DropdownMenuItem(
                          value: product,
                          child: Text(
                            product.name,
                          ),
                        );
                      }),
                      onChanged: (category) =>
                          setState(() => productSelected = category),
                      value: productSelected,
                      validator: (val) => productSelected == null
                          ? 'Silahkan Pilih Product'
                          : null,
                    ),
                  ),
//                  Card(
//                    child: TextFormField(
//                      controller: priceController,
//                      keyboardType: TextInputType.number,
//                      decoration: InputDecoration(
//                          labelText: 'Harga Retail Produk',
//                          contentPadding: EdgeInsets.all(12.0),
//                          enabledBorder: UnderlineInputBorder(
//                              borderSide:
//                                  BorderSide(color: Colors.transparent))),
//                      validator: (val) => val.isEmpty
//                          ? 'Silahkan Isi Harga Retail Produk'
//                          : null,
//                    ),
//                  ),
                  Card(
                    child: TextFormField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Jumlah Produk',
                          contentPadding: EdgeInsets.all(12.0),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.transparent))),
                      validator: (val) =>
                          val.isEmpty ? 'Silahkan Isi Jumlah Produk' : null,
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  void showLoading() {
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
                    child: Text("Tambah Produk. . ."),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
