import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/texts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure this is imported
import 'dart:async'; // For Future.delayed
import 'dart:math'; // For random AI responses

// --- Re-pasting Vintage Theme Elements for self-containment in this example ---
// (In a real app, these would be in a central theme file)

// --- End of Theme Elements ---

class BookAIChatWidget extends StatefulWidget {
  const BookAIChatWidget({super.key});

  @override
  State<BookAIChatWidget> createState() => _BookAIChatWidgetState();
}

class ChatMessage {
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    required this.timestamp,
  });
}

class _BookAIChatWidgetState extends State<BookAIChatWidget> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isAiTyping = false;

  @override
  void initState() {
    super.initState();
    // Initial AI greeting
    _addMessage("Hello! How can I help you find a good book today?", false);
  }

  void _addMessage(String text, bool isUser, {bool fromSend = false}) {
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          text: text,
          isUserMessage: isUser,
          timestamp: DateTime.now(),
        ),
      );
      if (fromSend) _isAiTyping = true; // AI starts "typing" after user sends
    });
    _scrollToBottom();
    if (isUser) {
      _textController.clear();
      _getAiResponse(text);
    }
  }

  void _getAiResponse(String userInput) {
    // Simulate AI thinking time
    Future.delayed(Duration(milliseconds: 800 + Random().nextInt(1200)), () {
      String response;
      userInput = userInput.toLowerCase();

      if (userInput.contains("recommend") || userInput.contains("suggest")) {
        const books = [
          "The Great Gatsby by F. Scott Fitzgerald",
          "To Kill a Mockingbird by Harper Lee",
          "1984 by George Orwell",
          "Pride and Prejudice by Jane Austen",
          "The Hobbit by J.R.R. Tolkien",
        ];
        response =
            "Certainly! How about trying '${books[Random().nextInt(books.length)]}'?";
      } else if (userInput.contains("fantasy")) {
        response =
            "For fantasy, 'The Name of the Wind' by Patrick Rothfuss is a great choice. Or perhaps 'Mistborn' by Brandon Sanderson?";
      } else if (userInput.contains("mystery") ||
          userInput.contains("thriller")) {
        response =
            "If you enjoy mysteries, 'The Da Vinci Code' is quite popular. For a classic, try Agatha Christie.";
      } else if (userInput.contains("hello") || userInput.contains("hi")) {
        response = "Hello there! What kind of books are you in the mood for?";
      } else if (userInput.contains("thank")) {
        response =
            "You're most welcome! Let me know if you need more suggestions.";
      } else {
        response =
            "That's an interesting thought. Could you tell me more about what you're looking for in a book?";
      }
      setState(() {
        _isAiTyping = false;
      });
      _addMessage(response, false);
    });
  }

  void _scrollToBottom() {
    // Scroll after a short delay to allow the ListView to update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final bool isUser = message.isUserMessage;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color:
              isUser
                  ? vintageGoldAccent.withOpacity(0.8)
                  : vintageBrown.withOpacity(0.85),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12.0),
            topRight: const Radius.circular(12.0),
            bottomLeft:
                isUser
                    ? const Radius.circular(12.0)
                    : const Radius.circular(0.0),
            bottomRight:
                isUser
                    ? const Radius.circular(0.0)
                    : const Radius.circular(12.0),
          ),
          boxShadow: [
            BoxShadow(
              color: vintageDarkBrown.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Text(
          message.text,
          style: vintageBaseTextStyle.copyWith(
            color: isUser ? vintageDarkBrown : vintageCream,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      //width: screenWidth * 0.35, // Adjusted to 0.35 for better usability
      // height: MediaQuery.of(context).size.height * 0.7, // Full height of the sidebar
      // Adjusted to 0.7 for better usability, 0.6 is too narrow
      // Adjusted to 0.65 for better usability, 0.6 is too narrow
      // Adjusted to 0.55 for better usability, 0.5 is too narrow
      // Adjusted to 0.35 for better usability, 0.3 is too narrow
      // Adjusted to 0.25 for better usability, 0.2 is very small
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.all(8.0),
        color: vintagePaper, // Vintage cream background

        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true, // To show latest messages at the bottom
                padding: const EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
            if (_isAiTyping)
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  bottom: 4.0,
                  top: 4.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "AI is typing...",
                    style: vintageBaseTextStyle.copyWith(
                      fontSize: 12,
                      color: vintageBrown.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            const Divider(height: 1.0, color: vintageBrown),
            _buildTextComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: vintageBrown),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        padding: const EdgeInsets.only(left: 12.0),
        decoration: BoxDecoration(
          color: vintageCream
              .withRed(240)
              .withGreen(220), // Slightly different shade for input
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: vintageBrown.withOpacity(0.5)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: (text) => _addMessage(text, true, fromSend: true),
                decoration: InputDecoration(
                  hintText: "Ask about books...",
                  hintStyle: vintageBaseTextStyle.copyWith(
                    color: vintageBrown.withOpacity(0.6),
                    fontSize: 15,
                  ),
                  border: InputBorder.none, // Remove default underline
                ),
                style: vintageBaseTextStyle.copyWith(fontSize: 15),
                cursorColor: vintageBrown,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded),
              color: vintageBrown,
              disabledColor: vintageBrown.withOpacity(0.5),
              onPressed:
                  _textController.text.trim().isNotEmpty
                      ? () => _addMessage(
                        _textController.text.trim(),
                        true,
                        fromSend: true,
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
