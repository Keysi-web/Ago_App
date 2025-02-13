import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting timestamps

class ChatSupportPage extends StatefulWidget {
  const ChatSupportPage({super.key});

  @override
  _ChatSupportPageState createState() => _ChatSupportPageState();
}

class _ChatSupportPageState extends State<ChatSupportPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();

  // Define response mapping
  final Map<String, List<String>> _responseMap = {
    'hello': [
      "Hi there! How can I assist you today?",
      "Hello! What can I do for you?",
      "Hey! How may I help you?"
    ],
    'help': [
      "Sure, I'm here to help! What do you need assistance with?",
      "I'd be happy to assist you. Could you please provide more details?"
    ],
    'problem': [
      "I'm sorry you're experiencing a problem. Could you elaborate?",
      "Let's get that sorted out. Can you describe the issue in more detail?"
    ],
    'thank': [
      "You're welcome! Let me know if you need anything else.",
      "Happy to help! Is there anything else I can assist you with?"
    ],
    'bye': [
      "Goodbye! Have a great day!",
      "Bye! Feel free to reach out if you need further assistance."
    ],
    // Add more keywords and responses as needed
  };

  // Default responses when no keywords match
  final List<String> _defaultResponses = [
    "I'm sorry, I didn't quite catch that. Could you please clarify?",
    "Could you please provide more information?",
    "I'm here to help! Can you elaborate on that?"
  ];

  // Send message handler
  void _sendMessage() {
    String text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(Message(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ));
        _messageController.clear();
      });
      _scrollToBottom();
      _simulateSupportResponse(text); // Trigger response generation
      // No backend integration needed for local logic
    }
  }

  // Simulate support responses using local logic
  void _simulateSupportResponse(String userMessage) {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        String response = "Support: I'm here to help! Could you please provide more details?"; // Default response

        // Convert user message to lowercase for case-insensitive matching
        String message = userMessage.toLowerCase();

        // Flag to check if any keyword matched
        bool matched = false;

        // Iterate through the response map
        _responseMap.forEach((keyword, responses) {
          if (message.contains(keyword)) {
            final random = Random();
            response = "Support: " + responses[random.nextInt(responses.length)];
            matched = true;
          }
        });

        // If no keywords matched, select a default response
        if (!matched) {
          final random = Random();
          response = "Support: " + _defaultResponses[random.nextInt(_defaultResponses.length)];
        }

        _messages.add(Message(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _scrollToBottom();
      });
    });
  }

  // Scroll to the bottom of the chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Helper to format timestamp
  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('hh:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Support'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final alignment =
    message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isUser ? Colors.green.shade700 : Colors.grey.shade300;
    final textColor = message.isUser ? Colors.white : Colors.black87;
    final avatar = message.isUser
        ? CircleAvatar(
      backgroundColor: Colors.green.shade700,
      child: const Icon(Icons.person, color: Colors.white),
    )
        : CircleAvatar(
      backgroundColor: Colors.grey.shade300,
      child: const Icon(Icons.support_agent, color: Colors.black87),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) avatar,
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(color: textColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(message.timestamp),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser) avatar,
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12.0).copyWith(bottom: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: const Offset(0, -1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.green.shade700,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
