import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/payment_method.dart';
import '../models/user_address.dart';

class UserDataService {
  UserDataService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _addresses(String uid) =>
      _firestore.collection('users').doc(uid).collection('addresses');

  CollectionReference<Map<String, dynamic>> _paymentMethods(String uid) =>
      _firestore.collection('users').doc(uid).collection('paymentMethods');

  CollectionReference<Map<String, dynamic>> _favorites(String uid) =>
      _firestore.collection('users').doc(uid).collection('favorites');

  Stream<List<UserAddress>> getAddresses(String uid) {
    return _addresses(uid).snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => UserAddress(
              id: doc.id,
              label: (doc.data()['label'] as String?) ?? '',
              details: (doc.data()['details'] as String?) ?? '',
            ),
          )
          .where((address) => address.label.isNotEmpty)
          .toList(),
    );
  }

  Stream<List<PaymentMethod>> getPaymentMethods(String uid) {
    return _paymentMethods(uid).snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => PaymentMethod(
              id: doc.id,
              label: (doc.data()['label'] as String?) ?? '',
              last4: (doc.data()['last4'] as String?) ?? '',
            ),
          )
          .where((method) => method.label.isNotEmpty)
          .toList(),
    );
  }

  Future<String> addAddress({
    required String uid,
    required String label,
    required String details,
  }) async {
    final doc = await _addresses(uid).add({
      'label': label,
      'details': details,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> removeAddress({required String uid, required String id}) {
    return _addresses(uid).doc(id).delete();
  }

  Future<String> addPaymentMethod({
    required String uid,
    required String label,
    required String last4,
  }) async {
    final doc = await _paymentMethods(uid).add({
      'label': label,
      'last4': last4,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> removePaymentMethod({required String uid, required String id}) {
    return _paymentMethods(uid).doc(id).delete();
  }

  Stream<Set<String>> getFavoriteIds(String uid) {
    return _favorites(
      uid,
    ).snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  Future<void> setFavorite({
    required String uid,
    required String productId,
    required bool isFavorite,
  }) {
    final ref = _favorites(uid).doc(productId);
    if (isFavorite) {
      return ref.set({'createdAt': FieldValue.serverTimestamp()});
    }
    return ref.delete();
  }
}
