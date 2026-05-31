import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/app_notification.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../models/payment_method.dart';
import '../models/product.dart';
import '../models/user_address.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/notification_service.dart';
import '../services/order_service.dart';
import '../services/product_service.dart';
import '../services/user_data_service.dart';

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.items,
    required this.total,
    required this.placedAt,
    required this.address,
    required this.paymentLabel,
    required this.status,
  });

  final String id;
  final List<String> items;
  final double total;
  final DateTime placedAt;
  final String address;
  final String paymentLabel;
  final String status;
}

class AppStateProvider extends ChangeNotifier {
  AppStateProvider({
    AuthService? authService,
    ProductService? productService,
    CartService? cartService,
    OrderService? orderService,
    UserDataService? userDataService,
    NotificationService? notificationService,
  }) : _authService = authService ?? AuthService(),
       _productService = productService ?? ProductService(),
       _cartService = cartService ?? CartService(),
       _orderService = orderService ?? OrderService(),
       _userDataService = userDataService ?? UserDataService(),
       _notificationService = notificationService ?? NotificationService() {
    _productsSub = _productService.getProducts().listen(
      (products) {
        _products = products;
        notifyListeners();
      },
      onError: (Object error) {
        _lastError = _messageFor(error);
        notifyListeners();
      },
    );
    _authSub = _authService.authStateChanges().listen(_onAuthChanged);
  }

  final AuthService _authService;
  final ProductService _productService;
  final CartService _cartService;
  final OrderService _orderService;
  final UserDataService _userDataService;
  final NotificationService _notificationService;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<Product>>? _productsSub;
  StreamSubscription<List<CartItem>>? _cartSub;
  StreamSubscription<List<OrderModel>>? _ordersSub;
  StreamSubscription<List<OrderModel>>? _adminOrdersSub;
  StreamSubscription<List<UserAddress>>? _addressesSub;
  StreamSubscription<List<PaymentMethod>>? _paymentMethodsSub;
  StreamSubscription<Set<String>>? _favoritesSub;
  StreamSubscription<List<AppNotification>>? _notificationsSub;

  int _tabIndex = 0;
  String _userName = 'Guest';
  String _userEmail = '';
  String _lastSignedInEmail = '';
  String _role = 'user';
  String? _uid;
  String? _lastError;
  bool _isBusy = false;
  List<Product> _products = [];
  List<CartItem> _cartItems = [];
  final Set<String> _favorites = {};
  final Map<String, int> _cart = {};
  final List<OrderRecord> _orders = [];
  List<AppNotification> _notifications = [];
  List<OrderModel> _adminOrders = [];
  List<UserAddress> _addresses = [];
  final List<PaymentMethod> _paymentMethods = [];
  String _selectedAddressId = '';
  String _selectedPaymentMethodId = '';

  int get tabIndex => _tabIndex;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get role => _role;
  String? get uid => _uid;
  String? get lastError => _lastError;
  bool get isBusy => _isBusy;
  bool get isLoggedIn => _uid != null;
  bool get isAdmin => _role == 'admin';
  List<Product> get products => _products;
  List<CartItem> get cartItems => _cartItems;
  Set<String> get favorites => _favorites;
  Map<String, int> get cart => _cart;
  List<OrderRecord> get orders => _orders;
  List<AppNotification> get notifications => _notifications;
  List<OrderModel> get adminOrders => _adminOrders;
  List<UserAddress> get addresses => _addresses;
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  UserAddress? get selectedAddress {
    if (_addresses.isEmpty) return null;
    return _addresses.firstWhere(
      (address) => address.id == _selectedAddressId,
      orElse: () => _addresses.first,
    );
  }

  PaymentMethod? get selectedPaymentMethod {
    if (_paymentMethods.isEmpty || _selectedPaymentMethodId.isEmpty) {
      return null;
    }
    return _paymentMethods.firstWhere(
      (method) => method.id == _selectedPaymentMethodId,
      orElse: () => _paymentMethods.first,
    );
  }

  int get cartItemCount =>
      _cart.values.fold(0, (sum, quantity) => sum + quantity);
  int get orderCount => _orders.length;
  int get unreadNotificationCount =>
      _notifications.where((notification) => !notification.isRead).length;
  int get points => _orders
      .where((order) => order.status == 'delivered')
      .fold<double>(0, (sum, order) => sum + order.total)
      .round();

  List<Product> get favoriteProducts =>
      _products.where((product) => _favorites.contains(product.id)).toList();

  List<Product> get cartProducts {
    return _cartItems
        .map(
          (item) => Product(
            id: item.productId,
            name: item.name,
            category: '',
            image: item.imageUrl,
            rating: 4.8,
            price: item.price,
            discount: 0,
            description: '',
            stock: item.stock,
          ),
        )
        .toList();
  }

  Product? productById(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  int cartQuantityFor(String productId) => _cart[productId] ?? 0;

  int stockFor(String productId) {
    final product = productById(productId);
    if (product != null) return product.stock;
    for (final item in _cartItems) {
      if (item.productId == productId) return item.stock;
    }
    return 0;
  }

  bool canAddToCart(String productId, {int quantity = 1}) {
    final stock = stockFor(productId);
    return stock > 0 && cartQuantityFor(productId) + quantity <= stock;
  }

  List<Product> productsByCategory(String category) {
    if (category == 'all' || category == 'organic') return _products;
    return _products.where((product) => product.category == category).toList();
  }

  void setTab(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  double get cartSubtotal {
    return _cartItems.fold<double>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
  }

  double get deliveryFee => cartSubtotal == 0 ? 0.0 : 35.0;
  double get cartTotal => cartSubtotal + deliveryFee;

  void updatePersonalInfo({required String name, required String email}) {
    _userName = name.trim().isEmpty ? _userName : name.trim();
    _userEmail = email.trim().isEmpty ? _userEmail : email.trim();
    _lastSignedInEmail = _userEmail;
    notifyListeners();
  }

  void setUser({required String name, required String email}) {
    final trimmedEmail = email.trim();
    final isDifferentUser =
        _lastSignedInEmail.isEmpty ||
        trimmedEmail.toLowerCase() != _lastSignedInEmail.toLowerCase();
    _userName = name.trim().isEmpty ? email.split('@').first : name.trim();
    _userEmail = trimmedEmail;
    _lastSignedInEmail = trimmedEmail;
    if (isDifferentUser) {
      _cart.clear();
      _orders.clear();
      _addresses.clear();
      _paymentMethods.clear();
      _selectedAddressId = '';
      _selectedPaymentMethodId = '';
      _tabIndex = 0;
    }
    notifyListeners();
  }

  void logout() {
    _authService.logout();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _runBusy(() async {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      _applyUser(user);
    });
  }

  Future<bool> login({required String email, required String password}) async {
    return _runBusy(() async {
      final user = await _authService.login(email: email, password: password);
      if (user != null) _applyUser(user);
    });
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final uid = _uid;
    if (uid == null) return;
    final isFavorite = !_favorites.contains(id);
    await _guard(
      () => _userDataService.setFavorite(
        uid: uid,
        productId: id,
        isFavorite: isFavorite,
      ),
    );
  }

  Future<void> addToCart(String id, {int quantity = 1}) async {
    final uid = _uid;
    final product = productById(id);
    if (isAdmin) {
      _lastError = 'Admins manage products and cannot place customer orders.';
      notifyListeners();
      return;
    }
    if (uid == null || product == null) {
      _lastError = uid == null
          ? 'Please sign in before adding items to your cart.'
          : 'Product was not found.';
      notifyListeners();
      return;
    }
    await _guard(
      () => _cartService.addToCart(
        uid: uid,
        product: product,
        quantity: quantity,
      ),
    );
  }

  Future<void> decrementCart(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _guard(() => _cartService.decreaseQuantity(uid: uid, productId: id));
  }

  Future<void> removeFromCart(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _guard(() => _cartService.removeFromCart(uid: uid, productId: id));
  }

  Future<void> addAddress({
    required String label,
    required String details,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    await _guard(() async {
      final id = await _userDataService.addAddress(
        uid: uid,
        label: label.trim(),
        details: details.trim(),
      );
      _selectedAddressId = id;
    });
  }

  void selectAddress(String id) {
    _selectedAddressId = id;
    notifyListeners();
  }

  Future<void> removeAddress(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _guard(() async {
      await _userDataService.removeAddress(uid: uid, id: id);
      if (_selectedAddressId == id) {
        _selectedAddressId = _addresses.isEmpty ? '' : _addresses.first.id;
      }
    });
  }

  Future<void> addPaymentMethod({
    required String label,
    required String cardNumber,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final digits = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final last4 = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : digits;
    await _guard(() async {
      final id = await _userDataService.addPaymentMethod(
        uid: uid,
        label: label.trim(),
        last4: last4,
      );
      _selectedPaymentMethodId = id;
    });
  }

  void selectPaymentMethod(String id) {
    _selectedPaymentMethodId = id;
    notifyListeners();
  }

  Future<void> removePaymentMethod(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _guard(() async {
      await _userDataService.removePaymentMethod(uid: uid, id: id);
      if (_selectedPaymentMethodId == id) {
        _selectedPaymentMethodId = _paymentMethods.isEmpty
            ? ''
            : _paymentMethods.first.id;
      }
    });
  }

  Future<bool> placeOrder({required String paymentLabel}) async {
    final uid = _uid;
    if (isAdmin) {
      _lastError = 'Admins manage products and cannot place customer orders.';
      notifyListeners();
      return false;
    }
    if (uid == null || _cartItems.isEmpty) return false;
    final placed = await _runBusy(
      () => _orderService.createOrderFromCart(
        uid: uid,
        items: _cartItems,
        totalPrice: cartTotal,
        address: selectedAddress?.details ?? 'No address selected',
        phone: 'N/A',
      ),
    );
    if (!placed) return false;
    _tabIndex = 3;
    notifyListeners();
    return true;
  }

  Future<void> addProduct(Product product) {
    if (!isAdmin) return _adminOnlyAction();
    return _guard(() async {
      final id = await _productService.addProduct(product);
      await _notifyOffer(product.copyWith(id: id));
    });
  }

  Future<void> updateProduct(Product product) {
    if (!isAdmin) return _adminOnlyAction();
    final previous = productById(product.id);
    return _guard(() async {
      await _productService.updateProduct(product);
      if (_shouldNotifyOffer(previous, product)) {
        await _notifyOffer(product);
      }
    });
  }

  Future<void> deleteProduct(String id) {
    if (!isAdmin) return _adminOnlyAction();
    return _guard(() => _productService.deleteProduct(id));
  }

  Future<void> increaseProductStock(String id, {int by = 1}) {
    if (!isAdmin) return _adminOnlyAction();
    return _guard(() => _productService.adjustStock(id: id, delta: by));
  }

  Future<void> decreaseProductStock(String id, {int by = 1}) {
    if (!isAdmin) return _adminOnlyAction();
    return _guard(() => _productService.adjustStock(id: id, delta: -by));
  }

  Future<void> seedDefaultProducts() {
    if (!isAdmin) return _adminOnlyAction();
    return _guard(() => _productService.seedDefaultProductsIfEmpty());
  }

  Future<void> _adminOnlyAction() async {
    _lastError = 'Only admins can manage products.';
    notifyListeners();
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) {
    if (!isAdmin) return _adminOnlyAction();
    return _guard(
      () => _orderService.updateOrderStatus(orderId: orderId, status: status),
    );
  }

  Future<void> cancelOrder(String orderId) {
    if (!isAdmin) return _adminOnlyAction();
    return _guard(() => _orderService.cancelOrder(orderId: orderId));
  }

  Future<void> deleteOrder(String orderId) {
    if (!isAdmin) return _adminOnlyAction();
    return _guard(() => _orderService.deleteOrder(orderId));
  }

  Future<void> cancelUserOrder(String orderId) {
    final uid = _uid;
    if (uid == null) return Future<void>.value();
    return _guard(() => _orderService.cancelOrder(orderId: orderId, uid: uid));
  }

  Future<void> _onAuthChanged(User? firebaseUser) async {
    await _cartSub?.cancel();
    await _ordersSub?.cancel();
    await _adminOrdersSub?.cancel();
    await _addressesSub?.cancel();
    await _paymentMethodsSub?.cancel();
    await _favoritesSub?.cancel();
    await _notificationsSub?.cancel();
    _cartItems = [];
    _orders.clear();
    _adminOrders = [];
    _notifications = [];
    _cart.clear();
    _favorites.clear();
    _addresses = [];
    _paymentMethods.clear();
    _selectedAddressId = '';
    _selectedPaymentMethodId = '';

    if (firebaseUser == null) {
      _uid = null;
      _role = 'user';
      _userName = 'Guest';
      _userEmail = '';
      _tabIndex = 0;
      notifyListeners();
      return;
    }

    _uid = firebaseUser.uid;
    try {
      final appUser = await _authService.getCurrentAppUser();
      _applyUser(
        appUser ?? _fallbackUserFromFirebaseUser(firebaseUser, role: 'user'),
      );
    } catch (error) {
      _applyUser(
        _fallbackUserFromFirebaseUser(
          firebaseUser,
          role: _roleForEmail(firebaseUser.email ?? ''),
        ),
      );
      _lastError = _messageFor(error);
      notifyListeners();
    }

    _listenToSavedUserData(firebaseUser.uid);
    _listenToNotifications(firebaseUser.uid);

    _cartSub = _cartService
        .getCartItems(firebaseUser.uid)
        .listen(
          (items) {
            _cartItems = items;
            _cart
              ..clear()
              ..addEntries(
                items.map((item) => MapEntry(item.productId, item.quantity)),
              );
            notifyListeners();
          },
          onError: (Object error) {
            _lastError = _messageFor(error);
            notifyListeners();
          },
        );

    _ordersSub = _orderService
        .getUserOrders(firebaseUser.uid)
        .listen(
          (orders) {
            _orders
              ..clear()
              ..addAll(orders.map(_toOrderRecord));
            notifyListeners();
          },
          onError: (Object error) {
            _lastError = _messageFor(error);
            notifyListeners();
          },
        );

    if (isAdmin) {
      _adminOrdersSub = _orderService.getAllOrdersForAdmin().listen(
        (orders) {
          _adminOrders = orders;
          notifyListeners();
        },
        onError: (Object error) {
          _lastError = _messageFor(error);
          notifyListeners();
        },
      );
    }
  }

  void _listenToSavedUserData(String uid) {
    _addressesSub = _userDataService
        .getAddresses(uid)
        .listen(
          (addresses) {
            _addresses = addresses;
            if (_selectedAddressId.isEmpty && addresses.isNotEmpty) {
              _selectedAddressId = addresses.first.id;
            } else if (addresses.every(
              (address) => address.id != _selectedAddressId,
            )) {
              _selectedAddressId = addresses.isEmpty ? '' : addresses.first.id;
            }
            notifyListeners();
          },
          onError: (Object error) {
            _lastError = _messageFor(error);
            notifyListeners();
          },
        );

    _paymentMethodsSub = _userDataService
        .getPaymentMethods(uid)
        .listen(
          (methods) {
            _paymentMethods
              ..clear()
              ..addAll(methods);
            if (_selectedPaymentMethodId.isEmpty && methods.isNotEmpty) {
              _selectedPaymentMethodId = methods.first.id;
            } else if (methods.every(
              (method) => method.id != _selectedPaymentMethodId,
            )) {
              _selectedPaymentMethodId = methods.isEmpty
                  ? ''
                  : methods.first.id;
            }
            notifyListeners();
          },
          onError: (Object error) {
            _lastError = _messageFor(error);
            notifyListeners();
          },
        );

    _favoritesSub = _userDataService
        .getFavoriteIds(uid)
        .listen(
          (favoriteIds) {
            _favorites
              ..clear()
              ..addAll(favoriteIds);
            notifyListeners();
          },
          onError: (Object error) {
            _lastError = _messageFor(error);
            notifyListeners();
          },
        );
  }

  void _listenToNotifications(String uid) {
    _notificationsSub = _notificationService
        .getNotifications(uid)
        .listen(
          (notifications) {
            _notifications = notifications;
            notifyListeners();
          },
          onError: (Object error) {
            if (_isPermissionDenied(error)) return;
            _lastError = _messageFor(error);
            notifyListeners();
          },
        );
  }

  Future<void> markNotificationsRead() async {
    final uid = _uid;
    if (uid == null || unreadNotificationCount == 0) return;
    try {
      await _notificationService.markAllRead(uid);
    } catch (error) {
      if (!_isPermissionDenied(error)) {
        _lastError = _messageFor(error);
        notifyListeners();
      }
    }
  }

  bool _shouldNotifyOffer(Product? previous, Product product) {
    if (product.discount <= 0) return false;
    return previous == null ||
        previous.discount != product.discount ||
        previous.price != product.price;
  }

  Future<void> _notifyOffer(Product product) async {
    if (product.discount <= 0) return;
    try {
      await _notificationService.createForCustomers(
        title: '${product.discount}% off ${product.name}',
        body: 'Limited offer is live now. Add it to your cart while it lasts.',
        productId: product.id.isEmpty ? null : product.id,
      );
    } catch (error) {
      if (!_isPermissionDenied(error)) rethrow;
    }
  }

  void _applyUser(AppUser user) {
    _userName = user.name.trim().isEmpty
        ? user.email.split('@').first
        : user.name;
    _userEmail = user.email;
    _lastSignedInEmail = user.email;
    _role = user.role;
    notifyListeners();
  }

  AppUser _fallbackUserFromFirebaseUser(
    User firebaseUser, {
    required String role,
  }) {
    final email = firebaseUser.email ?? '';
    return AppUser(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName ?? email.split('@').first,
      email: email,
      role: role,
      createdAt: DateTime.now(),
    );
  }

  String _roleForEmail(String email) {
    return email.trim().toLowerCase() == 'admin@quickcart.com'
        ? 'admin'
        : 'user';
  }

  OrderRecord _toOrderRecord(OrderModel order) {
    return OrderRecord(
      id: order.id,
      items: order.items
          .map((item) => '${item.quantity} x ${item.name}')
          .toList(),
      total: order.totalPrice,
      placedAt: order.createdAt,
      address: order.address,
      paymentLabel: 'Status: ${order.status}',
      status: order.status,
    );
  }

  Future<bool> _runBusy(Future<void> Function() action) async {
    _isBusy = true;
    _lastError = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (error) {
      _lastError = _messageFor(error);
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> _guard(Future<void> Function() action) async {
    _lastError = null;
    try {
      await action();
    } catch (error) {
      _lastError = _messageFor(error);
      notifyListeners();
    }
  }

  String _messageFor(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'invalid-credential' || 'wrong-password' || 'user-not-found' =>
          error.message ??
              'The email or password is incorrect. Check them and try again.',
        'email-already-in-use' =>
          'This email already has an account. Switch to Sign In.',
        'weak-password' =>
          'Use a stronger password with at least 6 characters.',
        'invalid-email' => 'Enter a valid email address.',
        _ => error.message ?? error.code,
      };
    }
    if (error is FirebaseException && error.plugin == 'cloud_firestore') {
      return switch (error.code) {
        'unavailable' =>
          'Firestore is temporarily unavailable. Check your connection and try again.',
        'permission-denied' =>
          'You do not have permission to access this Firestore data.',
        _ => error.message ?? error.code,
      };
    }
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Bad state: ', '');
  }

  bool _isPermissionDenied(Object error) {
    return error is FirebaseException && error.code == 'permission-denied';
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _productsSub?.cancel();
    _cartSub?.cancel();
    _ordersSub?.cancel();
    _adminOrdersSub?.cancel();
    _addressesSub?.cancel();
    _paymentMethodsSub?.cancel();
    _favoritesSub?.cancel();
    _notificationsSub?.cancel();
    super.dispose();
  }
}
