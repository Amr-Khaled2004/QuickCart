import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item.dart';
import '../models/order_model.dart';
import 'cart_service.dart';
import 'notification_service.dart';

class OrderService {
  OrderService({
    FirebaseFirestore? firestore,
    CartService? cartService,
    NotificationService? notificationService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _cartService = cartService ?? CartService(),
       _notificationService = notificationService ?? NotificationService();

  final FirebaseFirestore _firestore;
  final CartService _cartService;
  final NotificationService _notificationService;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');
  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

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
    final orderRef = _orders.doc();
    await _firestore.runTransaction((transaction) async {
      final productRefs = {
        for (final item in items) item.productId: _products.doc(item.productId),
      };
      final productSnapshots =
          <String, DocumentSnapshot<Map<String, dynamic>>>{};

      for (final entry in productRefs.entries) {
        productSnapshots[entry.key] = await transaction.get(entry.value);
      }

      for (final item in items) {
        final snapshot = productSnapshots[item.productId];
        if (snapshot == null || !snapshot.exists) {
          throw StateError('${item.name} is no longer available.');
        }

        final stock = ((snapshot.data()?['stock'] as num?) ?? 0).toInt();
        if (stock < item.quantity) {
          throw StateError(
            'Only $stock ${item.name} left in stock. Please update your cart.',
          );
        }
      }

      for (final item in items) {
        final productRef = productRefs[item.productId];
        if (productRef == null) continue;
        transaction.update(productRef, {
          'stock': FieldValue.increment(-item.quantity),
        });
      }

      final order = OrderModel(
        id: orderRef.id,
        userId: uid,
        items: items,
        totalPrice: totalPrice,
        status: 'pending',
        address: address,
        phone: phone,
        createdAt: DateTime.now(),
      );
      transaction.set(orderRef, order.toFirestore());
    });
    await _tryCreateNotification(
      uid: uid,
      title: 'Order placed',
      body: _messageForStatus('pending'),
      type: 'order',
      orderId: orderRef.id,
    );
    await _cartService.clearCart(uid);
    return orderRef.id;
  }

  Stream<List<OrderModel>> getUserOrders(String uid) {
    return _orders.where('userId', isEqualTo: uid).snapshots().map((snapshot) {
      final orders = snapshot.docs.map(OrderModel.fromFirestore).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
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
  }) async {
    final orderRef = _orders.doc(orderId);
    var changed = false;
    await _firestore.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);
      if (!orderSnapshot.exists) {
        throw StateError('Order was not found.');
      }

      final data = orderSnapshot.data() ?? {};
      final previousStatus = (data['status'] as String?) ?? 'pending';
      final stockRestored = (data['stockRestored'] as bool?) ?? false;

      if (previousStatus == status) return;
      changed = true;

      if (status != 'cancelled') {
        transaction.update(orderRef, {'status': status});
        return;
      }

      if (previousStatus == 'cancelled' || stockRestored) {
        transaction.update(orderRef, {
          'status': 'cancelled',
          'stockRestored': true,
        });
        return;
      }

      await _restoreOrderStock(transaction, data);
      transaction.update(orderRef, {
        'status': 'cancelled',
        'stockRestored': true,
      });
    });
    if (changed) {
      await _tryCreateOrderStatusNotification(orderId: orderId, status: status);
    }
  }

  Future<void> cancelOrder({required String orderId, String? uid}) async {
    final orderRef = _orders.doc(orderId);
    var changed = false;
    await _firestore.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);
      if (!orderSnapshot.exists) {
        throw StateError('Order was not found.');
      }

      final data = orderSnapshot.data() ?? {};
      if (uid != null && data['userId'] != uid) {
        throw StateError('You can only cancel your own orders.');
      }

      final previousStatus = (data['status'] as String?) ?? 'pending';
      final stockRestored = (data['stockRestored'] as bool?) ?? false;
      if (previousStatus == 'cancelled' || stockRestored) {
        transaction.update(orderRef, {
          'status': 'cancelled',
          'stockRestored': true,
        });
        return;
      }

      changed = true;
      await _restoreOrderStock(transaction, data);
      transaction.update(orderRef, {
        'status': 'cancelled',
        'stockRestored': true,
      });
    });
    if (!changed) return;
    final notificationUid = uid ?? await _userIdForOrder(orderId);
    await _tryCreateOrderStatusNotification(
      uid: notificationUid,
      orderId: orderId,
      status: 'cancelled',
    );
  }

  Future<void> deleteOrder(String orderId) async {
    final orderRef = _orders.doc(orderId);
    await _firestore.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);
      if (!orderSnapshot.exists) return;

      final data = orderSnapshot.data() ?? {};
      final previousStatus = (data['status'] as String?) ?? 'pending';
      final stockRestored = (data['stockRestored'] as bool?) ?? false;

      if (previousStatus != 'cancelled' && !stockRestored) {
        await _restoreOrderStock(transaction, data);
      }

      transaction.delete(orderRef);
    });
  }

  Future<void> _restoreOrderStock(
    Transaction transaction,
    Map<String, dynamic> data,
  ) async {
    final rawItems = (data['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>();
    final items = rawItems.map(_itemQuantityByProduct).toList();
    final productRefs = {
      for (final item in items) item.productId: _products.doc(item.productId),
    };

    for (final ref in productRefs.values) {
      await transaction.get(ref);
    }

    for (final item in items) {
      if (item.productId.isEmpty || item.quantity <= 0) continue;
      final productRef = productRefs[item.productId];
      if (productRef == null) continue;
      transaction.update(productRef, {
        'stock': FieldValue.increment(item.quantity),
      });
    }
  }

  Future<void> _tryCreateOrderStatusNotification({
    String? uid,
    required String orderId,
    required String status,
  }) async {
    final targetUid = uid ?? await _userIdForOrder(orderId);
    await _tryCreateNotification(
      uid: targetUid,
      title: 'Order ${status.replaceAll('_', ' ')}',
      body: _messageForStatus(status),
      type: 'order',
      orderId: orderId,
    );
  }

  String _messageForStatus(String status) {
    return switch (status) {
      'pending' => 'Your order was created and is waiting for confirmation.',
      'preparing' => 'Your groceries are being prepared.',
      'picked_up' => 'Your order has been picked up and is on the way.',
      'shipped' => 'Your order is out for delivery.',
      'delivered' => 'Your order was delivered. Enjoy your groceries!',
      'cancelled' => 'Your order was cancelled and stock has been restored.',
      _ => 'Your order status changed to ${status.replaceAll('_', ' ')}.',
    };
  }

  Future<String> _userIdForOrder(String orderId) async {
    final snapshot = await _orders.doc(orderId).get();
    return (snapshot.data()?['userId'] as String?) ?? '';
  }

  Future<void> _tryCreateNotification({
    required String uid,
    required String title,
    required String body,
    String type = 'info',
    String? orderId,
  }) async {
    if (uid.isEmpty) return;
    try {
      await _notificationService.create(
        uid: uid,
        title: title,
        body: body,
        type: type,
        orderId: orderId,
      );
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') rethrow;
    }
  }

  _OrderItemQuantity _itemQuantityByProduct(Map<String, dynamic> item) {
    return _OrderItemQuantity(
      productId: (item['productId'] as String?) ?? '',
      quantity: ((item['quantity'] as num?) ?? 0).toInt(),
    );
  }
}

class _OrderItemQuantity {
  const _OrderItemQuantity({required this.productId, required this.quantity});

  final String productId;
  final int quantity;
}
