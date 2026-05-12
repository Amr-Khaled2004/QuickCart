import 'package:flutter/foundation.dart';

import '../data/dummy_data.dart';
import '../models/product.dart';

class AppStateProvider extends ChangeNotifier {
  int _tabIndex = 0;
  String _userName = 'Guest';
  String _userEmail = '';
  final Set<String> _favorites = {'p2', 'p3', 'p9'};
  final Map<String, int> _cart = {};
  final List<String> _orders = [];

  int get tabIndex => _tabIndex;
  String get userName => _userName;
  String get userEmail => _userEmail;
  Set<String> get favorites => _favorites;
  Map<String, int> get cart => _cart;
  List<String> get orders => _orders;
  int get cartItemCount =>
      _cart.values.fold(0, (sum, quantity) => sum + quantity);
  int get orderCount => _orders.length;
  int get points => _orders.length * 20;

  List<Product> get favoriteProducts => DummyData.products
      .where((product) => _favorites.contains(product.id))
      .toList();

  List<Product> get cartProducts => DummyData.products
      .where((product) => _cart.containsKey(product.id))
      .toList();

  void setTab(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  void setUser({required String name, required String email}) {
    _userName = name.trim().isEmpty ? email.split('@').first : name.trim();
    _userEmail = email.trim();
    notifyListeners();
  }

  void toggleFavorite(String id) {
    _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id);
    notifyListeners();
  }

  void addToCart(String id) {
    _cart[id] = (_cart[id] ?? 0) + 1;
    notifyListeners();
  }

  void decrementCart(String id) {
    final current = _cart[id] ?? 0;
    if (current <= 1) {
      _cart.remove(id);
    } else {
      _cart[id] = current - 1;
    }
    notifyListeners();
  }

  void removeFromCart(String id) {
    _cart.remove(id);
    notifyListeners();
  }
}
