// profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import other necessary pages
import 'cart_page.dart'; // You might want to rename or remove if no longer used
import 'wallet_page.dart';
import 'help_center_page.dart';
import 'chat_support_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Will hold the selected profile image file.
  File? _profileImage;

  // ImagePicker instance to pick images from gallery/camera.
  final ImagePicker _picker = ImagePicker();

  // Method to pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Method to handle logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // Navigate to the login page and remove all previous routes
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the logged-in user's email from FirebaseAuth
    final String userEmail =
        FirebaseAuth.instance.currentUser?.email ?? 'No Email';

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background gradient
            Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade400,
                    Colors.green.shade900,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture and Email
                  Center(
                    child: Column(
                      children: [
                        // Profile Picture with "edit" icon
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: _profileImage == null
                                  ? const AssetImage(
                                  'assets/profile_placeholder.png')
                              as ImageProvider
                                  : FileImage(_profileImage!),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage, // Change profile picture
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(Icons.edit,
                                      color: Colors.green, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Show user's email
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            userEmail,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // My Orders and My Wallet Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.receipt_long, // Changed icon (optional)
                        color: Colors.purple,
                        title: 'My Orders', // Changed title
                        onTap: () {
                          // Navigate to My Orders page using named route
                          Navigator.pushNamed(context, '/orders'); // Updated route
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.account_balance_wallet,
                        color: Colors.orange,
                        title: 'My Wallet',
                        onTap: () {
                          // Navigate to My Wallet page using named route
                          Navigator.pushNamed(context, '/wallet');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Support Information Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Support Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.help_outline,
                              color: Colors.blue),
                          title: const Text('Help Center'),
                          onTap: () {
                            // Navigate to Help Center page
                            Navigator.pushNamed(context, '/help-center');
                          },
                        ),
                        ListTile(
                          leading:
                          const Icon(Icons.chat, color: Colors.green),
                          title: const Text('Chat Support'),
                          onTap: () {
                            // Navigate to Chat Support page
                            Navigator.pushNamed(context, '/chat-support');
                          },
                        ),
                        const SizedBox(height: 10),
                        // Logout Button
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // Background color
                              foregroundColor: Colors.white, // Text and icon color
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long), // Changed icon (optional)
            label: 'Orders', // Changed label
          ),
        ],
        currentIndex: 1, // Set the selected index to "Profile"
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // Handle navigation based on the tapped index
          switch (index) {
            case 0:
            // Navigate to Home Dashboard
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
            // Already on Profile, do nothing or refresh
              break;
            case 2:
            // Navigate to Favorites Page
              Navigator.pushNamed(context, '/favorites'); // Ensure '/favorites' route is defined
              break;
            case 3:
            // Navigate to Orders Page
              Navigator.pushNamed(context, '/orders'); // Updated route
              break;
          }
        },
      ),
    );
  }

  // Feature Card Widget
  Widget _buildFeatureCard({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
