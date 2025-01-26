import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  // List to store cart items
  final List<Map<String, dynamic>> _cartItems = [];

  // Getter to access cart items
  List<Map<String, dynamic>> get cartItems => _cartItems;

  // Add an item to the cart
  void addToCart(Map<String, dynamic> product) {
    _cartItems.add(product);
    notifyListeners(); // Notify listeners to update the UI
  }

  // Remove an item from the cart
  void removeFromCart(Map<String, dynamic> product) {
    _cartItems.remove(product);
    notifyListeners(); // Notify listeners to update the UI
  }

  // Get the total price of items in the cart
  double get totalPrice {
    return _cartItems.fold(
        0.0, (total, item) => total + (item['price'] * (item['quantity'] ?? 1)));
  }

  // Update the quantity of a product
  void updateQuantity(Map<String, dynamic> product, int quantity) {
    final index = _cartItems.indexOf(product);
    if (index != -1) {
      _cartItems[index]['quantity'] = quantity;
      notifyListeners();
    }
  }
}
