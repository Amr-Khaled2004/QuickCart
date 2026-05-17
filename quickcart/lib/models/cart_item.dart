import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  const CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.stock,
  });

  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;
  final int stock;

  factory CartItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CartItem(
      productId: (data['productId'] as String?) ?? doc.id,
      name: (data['name'] as String?) ?? '',
      price: ((data['price'] as num?) ?? 0).toDouble(),
      imageUrl: (data['imageUrl'] as String?) ?? '',
      quantity: ((data['quantity'] as num?) ?? 1).toInt(),
      stock: ((data['stock'] as num?) ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'stock': stock,
    };
  }
}
