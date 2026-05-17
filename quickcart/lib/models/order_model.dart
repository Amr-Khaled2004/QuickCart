import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_item.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.address,
    required this.phone,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalPrice;
  final String status;
  final String address;
  final String phone;
  final DateTime createdAt;

  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawItems = (data['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>();
    return OrderModel(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      items: rawItems
          .map(
            (item) => CartItem(
              productId: (item['productId'] as String?) ?? '',
              name: (item['name'] as String?) ?? '',
              price: ((item['price'] as num?) ?? 0).toDouble(),
              imageUrl: (item['imageUrl'] as String?) ?? '',
              quantity: ((item['quantity'] as num?) ?? 1).toInt(),
              stock: ((item['stock'] as num?) ?? 0).toInt(),
            ),
          )
          .toList(),
      totalPrice: ((data['totalPrice'] as num?) ?? 0).toDouble(),
      status: (data['status'] as String?) ?? 'pending',
      address: (data['address'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toFirestore()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'address': address,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
