import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/get_started_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/home_page.dart';
import 'models/cart_model.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
        '/onboarding': (context) => const OnboardingPage(), // Updated route
        '/home': (context) => const HomePage(username: ''), // Home route
      },
    );
  }
}
