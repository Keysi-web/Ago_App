import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// import your cart item and cart page
import 'cart_item.dart';
import 'cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  /// The Firestore document ID for the product
  final String productId;

  const ProductDetailPage({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  /// For example, let’s track quantity here so we can add that many items to the cart
  int quantity = 1;

  /// Fetch the product document from Firestore by ID
  Future<DocumentSnapshot> _getProductDoc() {
    return FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
  }

  void _incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<DocumentSnapshot>(
        future: _getProductDoc(),
        builder: (context, snapshot) {
          // 1. Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Error state
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          // 3. If the document doesn't exist
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Product not found"));
          }

          // 4. We have product data
          final docData = snapshot.data!.data() as Map<String, dynamic>;
          final productName = docData['productName'] ?? 'Untitled';
          final priceString = docData['price']?.toString() ?? '0.00';
          final double price = double.tryParse(priceString) ?? 0.0;
          final imageUrl = docData['imageUrl'] ??
              'https://via.placeholder.com/400'; // fallback image
          final description = docData['description'] ?? 'No description';
          final rating = docData['rating'] ?? 4.0;
          final reviewsCount = docData['reviewsCount'] ?? 0;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Image with Gradient Overlay
                    Stack(
                      children: [
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.green.withAlpha(204)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // If your imageUrl is a network URL:
                        Positioned.fill(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Text("Image error"));
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(128), // 50% opacity
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              productName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Product Details
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                        shadowColor: Colors.greenAccent,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "\$${price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Display star icons based on rating
                                  for (int i = 0; i < (rating is double ? rating.floor() : 4); i++)
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                  if (rating is double && (rating % 1) != 0)
                                    const Icon(Icons.star_half, color: Colors.amber, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "($reviewsCount reviews)",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Description:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Quantity Selector
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Quantity:",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green.withAlpha(26),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove, color: Colors.green),
                                          onPressed: _decrementQuantity,
                                        ),
                                        Text(
                                          "$quantity",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add, color: Colors.green),
                                          onPressed: _incrementQuantity,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add to Cart Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // 1. Create a CartItem
                          final cartItem = CartItem(
                            productId: widget.productId,
                            productName: productName,
                            price: price,
                            quantity: quantity,
                            imageUrl: imageUrl,
                          );

                          // 2. Add it to CartPage's static cartItems list
                          CartPage.cartItems.add(cartItem);

                          // 3. Navigate to the CartPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.shopping_cart, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Add to Cart", style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // Back Button
              Positioned(
                top: 40,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.green),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
