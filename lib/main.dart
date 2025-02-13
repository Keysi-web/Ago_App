import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/cart_page.dart';
import 'pages/get_started_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/home_page.dart';
import 'models/cart_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/profile_page.dart';
import 'pages/wallet_page.dart';
import 'pages/help_center_page.dart';
import 'pages/chat_support_page.dart';
import 'pages/login_page.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    //options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(), // Initialize the cart model
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PERG Shop',
      theme: ThemeData(
        primarySwatch: Colors.green, // Updated to green theme
      ),
      home: const GetStartedPage(), // Initial screen
      routes: {
        '/login': (context) => const LoginPage(),
        '/help-center': (context) => const HelpCenterPage(),
        '/chat-support': (context) => const ChatSupportPage(),
        '/profile': (context) => const ProfilePage(),
        '/cart': (context) => const CartPage(),        // Add CartPage route
        '/wallet': (context) => const WalletPage(),    // Add WalletPage route
        '/onboarding': (context) => const OnboardingPage(), // Updated route
        '/home': (context) => const HomePage(username: ''), // Home route
      },
    );
  }
}
