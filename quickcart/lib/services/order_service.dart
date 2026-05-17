import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item.dart';
import '../models/order_model.dart';
import 'cart_service.dart';

class OrderService {
  OrderService({FirebaseFirestore? firestore, CartService? cartService})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _cartService = cartService ?? CartService();

  final FirebaseFirestore _firestore;
  final CartService _cartService;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  Future<String> createOrderFromCart({
    required String uid,
    required List<CartItem> items,
    required double totalPrice,
    required String address,
    required String phone,
  }) async {
    if (items.isEmpty) {
      throw StateError('Cannot create an order with an empty cart.');
    }
    final doc = _orders.doc();
    final order = OrderModel(
      id: doc.id,
      userId: uid,
      items: items,
      totalPrice: totalPrice,
      status: 'pending',
      address: address,
      phone: phone,
      createdAt: DateTime.now(),
    );
    await doc.set(order.toFirestore());
    await _cartService.clearCart(uid);
    return doc.id;
  }

  Stream<List<OrderModel>> getUserOrders(String uid) {
    return _orders
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(OrderModel.fromFirestore).toList(),
        );
  }

  Stream<List<OrderModel>> getAllOrdersForAdmin() {
    return _orders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(OrderModel.fromFirestore).toList(),
        );
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) {
    return _orders.doc(orderId).update({'status': status});
  }
}
