import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  CartService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _cart(String uid) =>
      _firestore.collection('users').doc(uid).collection('cart');

  Stream<List<CartItem>> getCartItems(String uid) {
    return _cart(uid).snapshots().map(
      (snapshot) => snapshot.docs.map(CartItem.fromFirestore).toList(),
    );
  }

  Future<void> addToCart({
    required String uid,
    required Product product,
    int quantity = 1,
  }) async {
    final ref = _cart(uid).doc(product.id);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (snapshot.exists) {
        final current = ((snapshot.data()?['quantity'] as num?) ?? 0).toInt();
        transaction.update(ref, {
          'quantity': current + quantity,
          'stock': product.stock,
        });
      } else {
        transaction.set(
          ref,
          CartItem(
            productId: product.id,
            name: product.name,
            price: product.price,
            imageUrl: product.imageUrl,
            quantity: quantity,
            stock: product.stock,
          ).toFirestore(),
        );
      }
    });
  }

  Future<void> increaseQuantity({
    required String uid,
    required String productId,
  }) {
    return _cart(
      uid,
    ).doc(productId).update({'quantity': FieldValue.increment(1)});
  }

  Future<void> decreaseQuantity({
    required String uid,
    required String productId,
  }) async {
    final ref = _cart(uid).doc(productId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final quantity = ((snapshot.data()?['quantity'] as num?) ?? 0).toInt();
      if (quantity <= 1) {
        transaction.delete(ref);
      } else {
        transaction.update(ref, {'quantity': quantity - 1});
      }
    });
  }

  Future<void> removeFromCart({
    required String uid,
    required String productId,
  }) {
    return _cart(uid).doc(productId).delete();
  }

  Future<void> clearCart(String uid) async {
    final snapshot = await _cart(uid).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
