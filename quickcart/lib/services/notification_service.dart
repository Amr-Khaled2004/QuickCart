import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';

class NotificationService {
  NotificationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _notifications(String uid) =>
      _firestore.collection('users').doc(uid).collection('notifications');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<List<AppNotification>> getNotifications(String uid) {
    return _notifications(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(AppNotification.fromFirestore).toList(),
        );
  }

  Future<void> markAllRead(String uid) async {
    final unread = await _notifications(
      uid,
    ).where('isRead', isEqualTo: false).get();
    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> create({
    required String uid,
    required String title,
    required String body,
    String type = 'info',
    String? orderId,
    String? productId,
  }) {
    return _notifications(uid).add({
      'title': title,
      'body': body,
      'type': type,
      'orderId': orderId,
      'productId': productId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createForCustomers({
    required String title,
    required String body,
    String type = 'offer',
    String? productId,
  }) async {
    final users = await _users.get();
    final customerIds = users.docs
        .where((doc) => (doc.data()['role'] as String?) != 'admin')
        .map((doc) => doc.id);
    var batch = _firestore.batch();
    var writes = 0;

    Future<void> commitBatch() async {
      if (writes == 0) return;
      await batch.commit();
      batch = _firestore.batch();
      writes = 0;
    }

    for (final uid in customerIds) {
      batch.set(_notifications(uid).doc(), {
        'title': title,
        'body': body,
        'type': type,
        'productId': productId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      writes++;
      if (writes == 450) await commitBatch();
    }
    await commitBatch();
  }
}
