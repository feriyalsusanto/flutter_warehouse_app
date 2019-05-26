import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pina_warehouse/entity/product_entity.dart';

final CollectionReference productCollection =
    Firestore.instance.collection('product');

final CollectionReference categoryCollection =
    Firestore.instance.collection('category');

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
}
