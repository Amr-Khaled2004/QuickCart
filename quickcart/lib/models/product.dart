import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.rating,
    required this.price,
    required this.discount,
    required this.description,
    this.stock = 0,
    this.createdAt,
  });

  final String id;
  final String name;
  final String category;
  final String image;
  final double rating;
  final double price;
  final int discount;
  final String description;
  final int stock;
  final DateTime? createdAt;

  String get imageUrl => image;

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Product(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      image: (data['imageUrl'] as String?) ?? (data['image'] as String?) ?? '',
      rating: ((data['rating'] as num?) ?? 4.8).toDouble(),
      price: ((data['price'] as num?) ?? 0).toDouble(),
      discount: ((data['discount'] as num?) ?? 0).toInt(),
      description: (data['description'] as String?) ?? '',
      stock: ((data['stock'] as num?) ?? 0).toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': image,
      'category': category,
      'stock': stock,
      'rating': rating,
      'discount': discount,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? image,
    double? rating,
    double? price,
    int? discount,
    String? description,
    int? stock,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
