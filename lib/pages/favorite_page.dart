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
      // Gradient AppBar for consistency
      appBar: AppBar(
        title: const Text('My Favorites'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: favoritesRef.snapshots(),
        builder: (context, snapshot) {
          // 1. Error
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error loading favorites",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // 2. Loading
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // 3. No Favorites
          if (docs.isEmpty) {
            return _buildEmptyFavoritesView();
          }

          // 4. Favorites List
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              // Extract Firestore fields
              final productId = docs[index].id;
              final productName = data['productName'] ?? 'Untitled';
              final imageUrl = data['imageUrl'] ?? 'https://via.placeholder.com/400';

              // Safely parse price
              double price = 0.0;
              final rawPrice = data['price'];
              if (rawPrice is num) {
                price = rawPrice.toDouble();
              } else if (rawPrice is String) {
                price = double.tryParse(rawPrice) ?? 0.0;
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 3),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // Product image
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                      child: Image.network(
                        imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.error, color: Colors.red),
                          );
                        },
                      ),
                    ),

                    // Product info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product name
                            Text(
                              productName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),

                            // Price
                            Text(
                              "\$${price.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Add to cart button
                    IconButton(
                      icon: const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        // 1. Add the item to the static cart list
                        CartPage.cartItems.add(
                          CartItem(
                            productId: productId,
                            productName: productName,
                            price: price,
                            quantity: 1,
                            imageUrl: imageUrl, id: '',
                          ),
                        );

                        // 2. Navigate to the cart page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Builds a "No favorites yet" view, styled similarly to the "empty cart" design
  Widget _buildEmptyFavoritesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No favorites yet.",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
