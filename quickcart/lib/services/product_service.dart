import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/grocery_seed_data.dart';
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

  Future<void> adjustStock({required String id, required int delta}) async {
    final ref = _products.doc(id);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        throw StateError('Product was not found.');
      }
      final current = ((snapshot.data()?['stock'] as num?) ?? 0).toInt();
      final next = current + delta;
      if (next < 0) {
        throw StateError('Stock cannot be lower than zero.');
      }
      transaction.update(ref, {'stock': next});
    });
  }

  Future<void> deleteProduct(String id) => _products.doc(id).delete();

  Future<void> seedDefaultProductsIfEmpty() async {
    final existing = await _products.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _firestore.batch();
    for (final product in GrocerySeedData.products) {
      batch.set(_products.doc(product.id), product.toFirestore());
    }
    await batch.commit();
  }
}
