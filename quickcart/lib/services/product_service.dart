import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class ProductService {
  ProductService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  Stream<List<Product>> getProducts() {
    return _products
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(Product.fromFirestore)
              .where((product) => product.name.isNotEmpty)
              .toList(),
        );
  }

  Future<Product?> getProductById(String id) async {
    final doc = await _products.doc(id).get();
    if (!doc.exists) return null;
    return Product.fromFirestore(doc);
  }

  Future<String> addProduct(Product product) async {
    final doc = await _products.add(product.toFirestore());
    return doc.id;
  }

  Future<void> updateProduct(Product product) {
    return _products
        .doc(product.id)
        .set(product.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteProduct(String id) => _products.doc(id).delete();
}
