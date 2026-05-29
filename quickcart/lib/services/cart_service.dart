import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  CartService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _cart(String uid) =>
      _firestore.collection('users').doc(uid).collection('cart');
  DocumentReference<Map<String, dynamic>> _product(String productId) =>
      _firestore.collection('products').doc(productId);

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
    final productRef = _product(product.id);
    await _firestore.runTransaction((transaction) async {
      final productSnapshot = await transaction.get(productRef);
      if (!productSnapshot.exists) {
        throw StateError('Product was not found.');
      }
      final latest = productSnapshot.data() ?? {};
      final stock = ((latest['stock'] as num?) ?? 0).toInt();
      if (stock <= 0) {
        throw StateError('Only 0 items available in stock');
      }

      final snapshot = await transaction.get(ref);
      final current = snapshot.exists
          ? ((snapshot.data()?['quantity'] as num?) ?? 0).toInt()
          : 0;
      final next = current + quantity;
      if (current >= stock || next > stock) {
        throw StateError('Only $stock items available in stock');
      }

      final cartItem = CartItem(
        productId: product.id,
        name: (latest['name'] as String?) ?? product.name,
        price: ((latest['price'] as num?) ?? product.price).toDouble(),
        imageUrl:
            (latest['imageUrl'] as String?) ??
            (latest['image'] as String?) ??
            product.imageUrl,
        quantity: next,
        stock: stock,
      );
      if (snapshot.exists) {
        transaction.update(ref, cartItem.toFirestore());
      } else {
        transaction.set(ref, cartItem.toFirestore());
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
