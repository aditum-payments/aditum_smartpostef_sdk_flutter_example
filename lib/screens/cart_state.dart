import 'package:flutter/material.dart';
import 'pay_screen.dart'; // Para acessar Product

class CartState extends ChangeNotifier {
  final Map<Product, int> _cart = {};

  Map<Product, int> get cart => _cart;

  double get total => _cart.entries.fold(
      0, (sum, entry) => sum + entry.key.price * entry.value);

  int get cartCount => _cart.values.fold(0, (sum, qty) => sum + qty);

  void addToCart(Product product) {
    _cart[product] = (_cart[product] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromCart(Product product) {
    if (_cart[product] != null && _cart[product]! > 1) {
      _cart[product] = _cart[product]! - 1;
    } else {
      _cart.remove(product);
    }
    notifyListeners();
  }

  void clear() {
    _cart.clear();
    notifyListeners();
  }
}