import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.type = 'info',
    this.orderId,
    this.productId,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String type;
  final String? orderId;
  final String? productId;
  final bool isRead;

  factory AppNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AppNotification(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      body: (data['body'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: (data['type'] as String?) ?? 'info',
      orderId: data['orderId'] as String?,
      productId: data['productId'] as String?,
      isRead: (data['isRead'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'type': type,
      'orderId': orderId,
      'productId': productId,
      'isRead': isRead,
    };
  }
}
