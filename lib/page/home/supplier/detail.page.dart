import 'package:flutter/material.dart';
import 'package:pina_warehouse/entity/supplier_entity.dart';
import 'package:pina_warehouse/service/firebase_firestore_service.dart';

class SupplierDetailPage extends StatefulWidget {
  Supplier supplier;

  SupplierDetailPage({this.supplier});

  @override
  _SupplierDetailPageState createState() => _SupplierDetailPageState();
}

class _SupplierDetailPageState extends State<SupplierDetailPage> {
  GlobalKey<FormState> formKey = new GlobalKey();
  FirebaseFirestoreService db = new FirebaseFirestoreService();

  TextEditingController nameController;
  TextEditingController phoneController;

//  bool isDeletable = false;

  @override
  void initState() {
    nameController = TextEditingController();
    phoneController = TextEditingController();
    if (widget.supplier != null) {
      nameController.text = widget.supplier.name;
      phoneController.text = widget.supplier.phone;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detil Supplier'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              _submitSupplier();
            },
            iconSize: 24.0,
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Card(
                      child: TextFormField(
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Nama Supplier',
                            contentPadding: EdgeInsets.all(12.0),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent))),
                        validator: (val) =>
                            val.isEmpty ? 'Silahkan Isi Nama Supplier' : null,
                      ),
                    ),
                    Card(
                      child: TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: 'No. Telepon Supplier',
                            contentPadding: EdgeInsets.all(12.0),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent))),
                        validator: (val) => val.isEmpty
                            ? 'Silahkan Isi No. Telepon Supplier'
                            : null,
                      ),
                    )
                  ],
                ),
              ),
            )),
//            RaisedButton(
//              onPressed: () {
//                _showDeleteAlertDialog(context);
//              },
//              child: Text(
//                'Hapus Supplier',
//                style: TextStyle(color: Colors.white),
//              ),
//              color: Colors.red,
//            )
          ],
        ),
      ),
    );
  }

  _submitSupplier() async {
    showLoading(widget.supplier != null
        ? "Update Supplier. . ."
        : "Tambah Supplier. . .");
    bool result = await db.createSupplier(Supplier(
        widget.supplier != null ? widget.supplier.id : null,
        nameController.text,
        phoneController.text));
    Navigator.pop(context);
    Navigator.pop(context, result);
  }

  _showDeleteAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Permanen'),
            content: Text(
                'Apakah anda yakin ingin menghapus supplier ini ? (Data yang di hapus tidak dapat di kembalikan lagi)'),
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
                  bool result = await db.deleteSupplier(widget.supplier);
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
