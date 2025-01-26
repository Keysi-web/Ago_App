// cart_page.dart
import 'package:flutter/material.dart';
import 'cart_item.dart';

class CartPage extends StatefulWidget {
  /// A static list to collect all cart items.
  /// In real apps, use a proper state management or database.
  static List<CartItem> cartItems = [];

  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    double totalPrice = 0.0;
    for (var item in CartPage.cartItems) {
      totalPrice += (item.price * item.quantity);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.green,
      ),
      body: CartPage.cartItems.isEmpty
          ? const Center(
        child: Text("Your cart is empty!"),
      )
          : ListView.builder(
        itemCount: CartPage.cartItems.length,
        itemBuilder: (context, index) {
          final cartItem = CartPage.cartItems[index];
          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Image.network(
                cartItem.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, color: Colors.red);
                },
              ),
              title: Text(cartItem.productName),
              subtitle: Text(
                "\$${cartItem.price} x ${cartItem.quantity} = \$${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    CartPage.cartItems.removeAt(index);
                  });
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total: \$${totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Checkout logic here (e.g., place order).
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Checkout not implemented.")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Checkout"),
            ),
          ],
        ),
      ),
    );
  }
}
