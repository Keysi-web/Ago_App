import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting timestamps

// Define the FAQ data model
class FAQ {
  final String category;
  final String question;
  final String answer;

  FAQ({
    required this.category,
    required this.question,
    required this.answer,
  });
}

// Sample FAQs
final List<FAQ> faqs = [
  FAQ(
    category: 'Account',
    question: 'How do I reset my password?',
    answer: 'To reset your password, go to the login page and click on "Forgot Password". Follow the instructions sent to your email.',
  ),
  FAQ(
    category: 'Account',
    question: 'How do I change my email address?',
    answer: 'Navigate to your account settings and update your email address under the "Personal Information" section.',
  ),
  FAQ(
    category: 'Billing',
    question: 'What payment methods are accepted?',
    answer: 'Choose a payment method.',
  ),
  FAQ(
    category: 'Billing',
    question: 'Can I get a refund?',
    answer: 'Refunds are available within 30 days of purchase. Please contact our support team for assistance.',
  ),
  FAQ(
    category: 'Technical',
    question: 'How do I report a bug?',
    answer: 'Please report bugs by navigating to the "Support" section and filling out the bug report form.',
  ),
  FAQ(
    category: 'Technical',
    question: 'Is there a mobile app available?',
    answer: 'Yes, our mobile app is available for both iOS and Android devices. You can download it from the App Store or Google Play Store.',
  ),
  // Add more FAQs as needed
];

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  _HelpCenterPageState createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();
  List<FAQ> _filteredFaqs = faqs;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterFaqs);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFaqs);
    _searchController.dispose();
    super.dispose();
  }

  void _filterFaqs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFaqs = faqs;
      } else {
        _filteredFaqs = faqs.where((faq) {
          return faq.question.toLowerCase().contains(query) ||
              faq.answer.toLowerCase().contains(query) ||
              faq.category.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Group FAQs by category
    Map<String, List<FAQ>> categorizedFaqs = {};
    for (var faq in _filteredFaqs) {
      if (categorizedFaqs.containsKey(faq.category)) {
        categorizedFaqs[faq.category]!.add(faq);
      } else {
        categorizedFaqs[faq.category] = [faq];
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: FAQSearchDelegate(faqs: faqs),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _filteredFaqs.isEmpty
            ? const Center(
          child: Text(
            'No FAQs found matching your query.',
            style: TextStyle(fontSize: 16),
          ),
        )
            : ListView(
          children: categorizedFaqs.entries.map((entry) {
            return _buildCategorySection(entry.key, entry.value);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String category, List<FAQ> faqs) {
    IconData categoryIcon;

    // Assign icons based on category
    switch (category.toLowerCase()) {
      case 'account':
        categoryIcon = Icons.person;
        break;
      case 'billing':
        categoryIcon = Icons.payment;
        break;
      case 'technical':
        categoryIcon = Icons.computer;
        break;
      default:
        categoryIcon = Icons.help_outline;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(categoryIcon, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Text(
              category,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...faqs.map((faq) => Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              faq.question,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  faq.answer,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Custom Search Delegate for FAQs
class FAQSearchDelegate extends SearchDelegate {
  final List<FAQ> faqs;

  FAQSearchDelegate({required this.faqs});

  @override
  String get searchFieldLabel => 'Search FAQs';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = faqs.where((faq) {
      final searchLower = query.toLowerCase();
      return faq.question.toLowerCase().contains(searchLower) ||
          faq.answer.toLowerCase().contains(searchLower) ||
          faq.category.toLowerCase().contains(searchLower);
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('No FAQs found matching your query.'),
      );
    }

    // Group results by category
    Map<String, List<FAQ>> categorizedResults = {};
    for (var faq in results) {
      if (categorizedResults.containsKey(faq.category)) {
        categorizedResults[faq.category]!.add(faq);
      } else {
        categorizedResults[faq.category] = [faq];
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: categorizedResults.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getCategoryIcon(entry.key),
                const SizedBox(width: 8),
                Text(
                  entry.key,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...entry.value.map((faq) => Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                title: Text(
                  faq.question,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      faq.answer,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = faqs.where((faq) {
      final searchLower = query.toLowerCase();
      return faq.question.toLowerCase().contains(searchLower) ||
          faq.answer.toLowerCase().contains(searchLower) ||
          faq.category.toLowerCase().contains(searchLower);
    }).toList();

    if (suggestions.isEmpty) {
      return const Center(
        child: Text('No FAQs found matching your query.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final faq = suggestions[index];
        return ListTile(
          title: Text(faq.question),
          subtitle: Text(faq.category),
          onTap: () {
            query = faq.question;
            showResults(context);
          },
        );
      },
    );
  }

  Icon _getCategoryIcon(String category) {
    IconData categoryIcon;

    switch (category.toLowerCase()) {
      case 'account':
        categoryIcon = Icons.person;
        break;
      case 'billing':
        categoryIcon = Icons.payment;
        break;
      case 'technical':
        categoryIcon = Icons.computer;
        break;
      default:
        categoryIcon = Icons.help_outline;
    }

    return Icon(categoryIcon, color: Colors.green.shade700);
  }
}
