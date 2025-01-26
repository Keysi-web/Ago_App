import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'profile_page.dart';
import 'product_detail_page.dart';
import 'cart_page.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  final String? username;

  const HomePage({Key? key, this.username}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _hoveredCategory = "";
  String? _selectedCategory; // <-- Stores current selected category filter (null = all)

  // Carousel images
  final List<String> _carouselImages = [
    "assets/images/pic1.png",
    "assets/images/pic2.jpg",
    "assets/images/pic3.png",
  ];

  // Static categories
  final List<Map<String, dynamic>> _categories = [
    {"icon": Icons.local_florist, "label": "Fruits"},
    {"icon": Icons.local_grocery_store, "label": "Vegetables"},
    {"icon": Icons.pets, "label": "Livestock"},
    {"icon": Icons.home_repair_service, "label": "Materials"},
    {"icon": Icons.category, "label": "Others"},
  ];

  @override
  Widget build(BuildContext context) {
    // Pages for your bottom navigation (though 2-4 are placeholders in your example)
    final List<Widget> pages = [
      _buildHomePageContent(),
      const Center(child: Text("Favorites Page Placeholder")),
      const Center(child: Text("Cart Page Placeholder")),
      const Center(child: Text("Another Placeholder")),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          // When tapped, show ProfilePage
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          // Cart
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          // Favorites
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            // Show the ProfilePage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          } else if (index == 2) {
            // Show the CartPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          } else if (index == 3) {
            // Show the FavoritePage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritePage()),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
    );
  }

  Widget _buildHomePageContent() {
    // Build a query that depends on _selectedCategory
    final productsRef = FirebaseFirestore.instance.collection('products');
    final productStream = (_selectedCategory == null)
        ? productsRef.snapshots() // Show ALL products
        : productsRef.where('category', isEqualTo: _selectedCategory).snapshots();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search keywords..',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF1F3F4),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.tune, color: Colors.grey),
              onPressed: () {
                // filter logic here
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Free Consultation Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/consultant.png',
                      width: 70,
                      height: 70,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Free Consultation",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Get free support from our customer service",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("Call Now"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Carousel
              SizedBox(
                height: 200,
                child: Swiper(
                  itemBuilder: (BuildContext context, int index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        _carouselImages[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  itemCount: _carouselImages.length,
                  autoplay: true,
                  pagination: const SwiperPagination(),
                  control: const SwiperControl(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Categories",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Categories row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((category) {
                    return GestureDetector(
                      onTap: () {
                        // When tapped, set the selected category
                        setState(() {
                          _selectedCategory = category['label'];
                        });
                      },
                      child: MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            _hoveredCategory = category["label"];
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            _hoveredCategory = "";
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor:
                                _hoveredCategory == category["label"]
                                    ? Colors.green[300]
                                    : Colors.green[100],
                                child: Icon(
                                  category["icon"],
                                  size: 30,
                                  color: _hoveredCategory == category["label"]
                                      ? Colors.white
                                      : Colors.green,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                category["label"],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              // "Featured Products" + "See All" row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Featured Products",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        // Reset category filter to see all products
                        _selectedCategory = null;
                      });
                    },
                    child: const Text(
                      "See All",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Firestore products grid
              StreamBuilder<QuerySnapshot>(
                stream: productStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading products"));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Text("No products found in Firestore");
                  }

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final productId = doc.id;
                      final productName = data['productName'] ?? 'Untitled';
                      final price = data['price']?.toString() ?? '0.00';
                      final imageUrl =
                          data['imageUrl'] ?? 'https://via.placeholder.com/400';

                      return GestureDetector(
                        onTap: () {
                          // Navigate to product detail page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(
                                productId: productId,
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15),
                                      ),
                                      child: Image.network(
                                        imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Center(
                                            child: Text("Image load error"),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          productName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "\$$price",
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Heart icon in the top-right corner
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.green,
                                child: IconButton(
                                  icon: const Icon(Icons.favorite_border,
                                      color: Colors.white),
                                  onPressed: () async {
                                    final favoritesRef = FirebaseFirestore.instance
                                        .collection('favorites');
                                    final docRef = favoritesRef.doc(productId);

                                    // Check if it's already in "favorites"
                                    final docSnapshot = await docRef.get();
                                    if (docSnapshot.exists) {
                                      // Already in favorites
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Already in favorites"),
                                        ),
                                      );
                                    } else {
                                      // Not in favorites yet, add it
                                      await docRef.set({
                                        'productId': productId,
                                        'productName': productName,
                                        'price': price,
                                        'imageUrl': imageUrl,
                                      });

                                      // Navigate to the FavoritePage
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                          const FavoritePage(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
