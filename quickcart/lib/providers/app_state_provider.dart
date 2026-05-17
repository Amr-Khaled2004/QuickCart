import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/dummy_data.dart';
import '../models/app_user.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/product_service.dart';

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.items,
    required this.total,
    required this.placedAt,
    required this.address,
    required this.paymentLabel,
  });

  final String id;
  final List<String> items;
  final double total;
  final DateTime placedAt;
  final String address;
  final String paymentLabel;
}

class UserAddress {
  const UserAddress({
    required this.id,
    required this.label,
    required this.details,
  });

  final String id;
  final String label;
  final String details;
}

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.label,
    required this.last4,
  });

  final String id;
  final String label;
  final String last4;
}

class AppStateProvider extends ChangeNotifier {
  AppStateProvider({
    AuthService? authService,
    ProductService? productService,
    CartService? cartService,
    OrderService? orderService,
  }) : _authService = authService ?? AuthService(),
       _productService = productService ?? ProductService(),
       _cartService = cartService ?? CartService(),
       _orderService = orderService ?? OrderService() {
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

  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<Product>>? _productsSub;
  StreamSubscription<List<CartItem>>? _cartSub;
  StreamSubscription<List<OrderModel>>? _ordersSub;

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
  final Set<String> _favorites = {'p2', 'p3', 'p9'};
  final Map<String, int> _cart = {};
  final List<OrderRecord> _orders = [];
  final List<UserAddress> _addresses = [
    const UserAddress(
      id: 'addr-home',
      label: 'Home',
      details: 'Cairo Festival City, New Cairo',
    ),
  ];
  final List<PaymentMethod> _paymentMethods = [];
  String _selectedAddressId = 'addr-home';
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
  int get points => _orders.length * 20;

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
    for (final product in DummyData.products) {
      if (product.id == id) return product;
    }
    return null;
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
      _favorites.clear();
      _cart.clear();
      _orders.clear();
      _addresses
        ..clear()
        ..add(
          const UserAddress(
            id: 'addr-home',
            label: 'Home',
            details: 'Cairo Festival City, New Cairo',
          ),
        );
      _paymentMethods.clear();
      _selectedAddressId = 'addr-home';
      _selectedPaymentMethodId = '';
      _tabIndex = 0;
    }
    notifyListeners();
  }

  void logout() {
    _authService.logout();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _runBusy(
      () => _authService.register(name: name, email: email, password: password),
    );
  }

  Future<void> login({required String email, required String password}) async {
    await _runBusy(() => _authService.login(email: email, password: password));
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id);
    notifyListeners();
  }

  Future<void> addToCart(String id, {int quantity = 1}) async {
    final uid = _uid;
    final product = productById(id);
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

  void addAddress({required String label, required String details}) {
    final id = 'addr-${DateTime.now().microsecondsSinceEpoch}';
    _addresses.add(
      UserAddress(id: id, label: label.trim(), details: details.trim()),
    );
    _selectedAddressId = id;
    notifyListeners();
  }

  void selectAddress(String id) {
    _selectedAddressId = id;
    notifyListeners();
  }

  void removeAddress(String id) {
    _addresses.removeWhere((address) => address.id == id);
    if (_selectedAddressId == id) {
      _selectedAddressId = _addresses.isEmpty ? '' : _addresses.first.id;
    }
    notifyListeners();
  }

  void addPaymentMethod({required String label, required String cardNumber}) {
    final digits = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final last4 = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : digits;
    final id = 'pay-${DateTime.now().microsecondsSinceEpoch}';
    _paymentMethods.add(
      PaymentMethod(id: id, label: label.trim(), last4: last4),
    );
    _selectedPaymentMethodId = id;
    notifyListeners();
  }

  void selectPaymentMethod(String id) {
    _selectedPaymentMethodId = id;
    notifyListeners();
  }

  void removePaymentMethod(String id) {
    _paymentMethods.removeWhere((method) => method.id == id);
    if (_selectedPaymentMethodId == id) {
      _selectedPaymentMethodId = _paymentMethods.isEmpty
          ? ''
          : _paymentMethods.first.id;
    }
    notifyListeners();
  }

  Future<void> placeOrder({required String paymentLabel}) async {
    final uid = _uid;
    if (uid == null || _cartItems.isEmpty) return;
    await _runBusy(
      () => _orderService.createOrderFromCart(
        uid: uid,
        items: _cartItems,
        totalPrice: cartTotal,
        address: selectedAddress?.details ?? 'No address selected',
        phone: 'N/A',
      ),
    );
    _tabIndex = 3;
    notifyListeners();
  }

  Future<void> addProduct(Product product) =>
      _guard(() => _productService.addProduct(product));

  Future<void> updateProduct(Product product) =>
      _guard(() => _productService.updateProduct(product));

  Future<void> deleteProduct(String id) =>
      _guard(() => _productService.deleteProduct(id));

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) {
    return _guard(
      () => _orderService.updateOrderStatus(orderId: orderId, status: status),
    );
  }

  Future<void> _onAuthChanged(User? firebaseUser) async {
    await _cartSub?.cancel();
    await _ordersSub?.cancel();
    _cartItems = [];
    _orders.clear();
    _cart.clear();

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
    final appUser = await _authService.getCurrentAppUser();
    _applyUser(
      appUser ??
          AppUser(
            uid: firebaseUser.uid,
            name:
                firebaseUser.displayName ??
                firebaseUser.email?.split('@').first ??
                'Shopper',
            email: firebaseUser.email ?? '',
            role: 'user',
            createdAt: DateTime.now(),
          ),
    );

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
    );
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    _isBusy = true;
    _lastError = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _lastError = _messageFor(error);
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
      return error.message ?? error.code;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _productsSub?.cancel();
    _cartSub?.cancel();
    _ordersSub?.cancel();
    super.dispose();
  }
}
