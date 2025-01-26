import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_page.dart';
import 'cart_item.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoritesRef = FirebaseFirestore.instance.collection('favorites');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: favoritesRef.snapshots(),
        builder: (context, snapshot) {
          // 1. Error
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading favorites"),
            );
          }
          // 2. Loading
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No favorites yet."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              // Extract Firestore fields
              final productId = docs[index].id; // or another unique ID
              final productName = data['productName'] ?? 'Untitled';

              // Safely parse price, which might be stored as String or num
              final rawPrice = data['price'];
              double price = 0.0;
              if (rawPrice is num) {
                // If Firestore stored it as int/double
                price = rawPrice.toDouble();
              } else if (rawPrice is String) {
                // If Firestore stored it as String
                price = double.tryParse(rawPrice) ?? 0.0;
              }

              // Or simply:
              // double price = double.tryParse(data['price'].toString()) ?? 0.0;

              final imageUrl = data['imageUrl'] ?? 'https://via.placeholder.com/400';

              return ListTile(
                leading: Image.network(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error),
                ),
                title: Text(productName),
                subtitle: Text("\$${price.toStringAsFixed(2)}"),
                trailing: IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () {
                    // 1. Add the item to the static cart list
                    CartPage.cartItems.add(
                      CartItem(
                        productId: productId,
                        productName: productName,
                        price: price,
                        quantity: 1, // default quantity
                        imageUrl: imageUrl,
                      ),
                    );

                    // 2. Navigate to the cart page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartPage()),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
