import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pina_warehouse/entity/activity_entity.dart';
import 'package:pina_warehouse/entity/product_entity.dart';
import 'package:pina_warehouse/entity/stock_entity.dart';
import 'package:pina_warehouse/entity/supplier_entity.dart';

final CollectionReference productCollection =
    Firestore.instance.collection('product');

final CollectionReference categoryCollection =
    Firestore.instance.collection('category');

final CollectionReference activityCollection =
    Firestore.instance.collection('activity');

final CollectionReference supplierCollection =
    Firestore.instance.collection('supplier');

final CollectionReference stockCollection =
    Firestore.instance.collection('stock');

class FirebaseFirestoreService {
  static final FirebaseFirestoreService _instance =
      new FirebaseFirestoreService.internal();

  factory FirebaseFirestoreService() => _instance;

  FirebaseFirestoreService.internal();

  Stream<QuerySnapshot> getProductList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = productCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Future<bool> createProduct(Product product) async {
    bool success = true;
    await productCollection.add(product.toMap()).catchError((e) {
      print(e.toString());
      success = false;
    });
    return success;
  }

  Future<void> updateProduct(String uid, Product product) async {
    DocumentReference productRef = productCollection.document(uid);
    var result = await productRef.updateData(product.toMap()).catchError((e) {
      print(e.toString());
    });
    return result;
  }

  Future<bool> deleteProduct(String id) async {
    bool success = true;
    await productCollection.document(id).delete().catchError((error) {
      success = false;
    });

    return success;
  }

  Stream<QuerySnapshot> getCategoryList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = categoryCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Stream<QuerySnapshot> getActivityList(bool status) {
    Query query = activityCollection.where('status', isEqualTo: status);
    Stream<QuerySnapshot> snapshots = query.snapshots();

    return snapshots;
  }

  Future<bool> createActivity(Activity activity) async {
    bool success = true;

    activity.product.forEach((product) async {
      await updateStock(product, isDelete: activity.isOut);
    });

    await activityCollection.add(activity.toMap()).catchError((e) {
      success = false;
    });

    return success;
  }

  Future<bool> deleteActivity(Activity activity, int type) async {
    bool success = true;

    print('type $type');

    activity.product.forEach((product) async {
      if (type == 1)
        await updateStock(product, isDelete: true);
      else
        await updateStock(product, isDelete: false);
    });

    await activityCollection.document(activity.id).delete().catchError((error) {
      success = false;
    });

    return success;
  }

  Stream<QuerySnapshot> getSupplierList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = supplierCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Future<bool> createSupplier(Supplier supplier) async {
    bool success = true;

    if (supplier.id == null)
      await supplierCollection.add(supplier.toMap()).catchError((e) {
        print(e.toString());
        success = false;
      });
    else {
      DocumentReference supplierRef = supplierCollection.document(supplier.id);
      await supplierRef.updateData(supplier.toMap()).catchError((e) {
        print(e.toString());
        success = false;
      });
    }

    return success;
  }

  Future<bool> deleteSupplier(Supplier supplier) async {
    bool success = true;

    await supplierCollection.document(supplier.id).delete().catchError((error) {
      success = false;
    });

    return success;
  }

  Future<bool> updateStock(ActivityProduct product,
      {bool isDelete = false}) async {
    DocumentReference documentReference = stockCollection.document(product.id);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> stock = documentSnapshot.data;
      int qty = documentSnapshot.data['product_qty'];
      int dataQty = product.qty;
      int updateQty = 0;
      print(isDelete);
      if (!isDelete) {
        updateQty = qty + dataQty;
      } else {
        updateQty = qty - dataQty;
      }
      stock['product_qty'] = updateQty;
      bool success = true;
      await documentReference.updateData(stock).catchError((e) {
        success = false;
      });
      return success;
    } else {
      Stock stock = Stock(product.id, product.id, product.qty);
      bool success = true;
      await stockCollection
          .document(product.id)
          .setData(stock.toMap())
          .catchError((e) {
        success = false;
      });
      return success;
    }
  }

  Stream<QuerySnapshot> getStockList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = stockCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }
}
