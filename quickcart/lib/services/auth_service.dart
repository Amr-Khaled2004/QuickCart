import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  static const _adminEmail = 'admin@quickcart.com';

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name);
    final appUser = AppUser(
      uid: user.uid,
      name: name,
      email: email,
      role: _roleForEmail(email),
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(appUser.toFirestore(), SetOptions(merge: true));
    return appUser;
  }

  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    final credential = await _signInOrCreateBootstrapAdmin(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) return null;

    final userRef = _firestore.collection('users').doc(user.uid);
    try {
      final doc = await userRef.get();
      if (!doc.exists) {
        final appUser = _appUserFromAuthUser(user: user, email: email);
        await userRef.set(appUser.toFirestore(), SetOptions(merge: true));
        return appUser;
      }

      final appUser = AppUser.fromFirestore(doc);
      if (_isBootstrapAdminEmail(email) && !appUser.isAdmin) {
        final adminUser = AppUser(
          uid: appUser.uid,
          name: appUser.name.isEmpty ? email.split('@').first : appUser.name,
          email: appUser.email.isEmpty ? email : appUser.email,
          role: 'admin',
          createdAt: appUser.createdAt,
        );
        await userRef.set(adminUser.toFirestore(), SetOptions(merge: true));
        return adminUser;
      }
      return appUser;
    } on FirebaseException catch (error) {
      if (!_isBootstrapAdminEmail(email) || !_isFirestoreUnavailable(error)) {
        rethrow;
      }
      return _appUserFromAuthUser(user: user, email: email, role: 'admin');
    }
  }

  Future<void> logout() => _auth.signOut();

  Future<UserCredential> _signInOrCreateBootstrapAdmin({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      final canBootstrap =
          _isBootstrapAdminEmail(email) &&
          (error.code == 'invalid-credential' ||
              error.code == 'user-not-found');
      if (!canBootstrap) rethrow;

      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await credential.user?.updateDisplayName('Admin');
        return credential;
      } on FirebaseAuthException catch (createError) {
        if (createError.code == 'email-already-in-use') {
          throw FirebaseAuthException(
            code: 'wrong-password',
            message:
                'The admin account already exists. Use its saved password or reset it.',
          );
        }
        rethrow;
      }
    }
  }

  String _roleForEmail(String email) {
    return _isBootstrapAdminEmail(email) ? 'admin' : 'user';
  }

  bool _isBootstrapAdminEmail(String email) {
    return email.trim().toLowerCase() == _adminEmail;
  }

  bool _isFirestoreUnavailable(FirebaseException error) {
    return error.plugin == 'cloud_firestore' && error.code == 'unavailable';
  }

  AppUser _appUserFromAuthUser({
    required User user,
    required String email,
    String? role,
  }) {
    return AppUser(
      uid: user.uid,
      name: user.displayName ?? email.split('@').first,
      email: email,
      role: role ?? _roleForEmail(email),
      createdAt: DateTime.now(),
    );
  }
}
