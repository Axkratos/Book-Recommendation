// lib/widgets/chat_widget.dart
import 'package:bookrec/theme/color.dart'; // Your color definitions
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({Key? key}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  // The state for the chat window is now managed within this widget
  bool _isChatOpen = false;

  @override
  Widget build(BuildContext context) {
    // This widget is positioned at the bottom right of its parent Stack
    return Positioned(
      bottom: 32,
      right: 32,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        // A nice transition for opening/closing the chat
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(child: child, scale: animation);
        },
        child: _isChatOpen
            // Using a Key helps AnimatedSwitcher differentiate the widgets
            ? _buildChatWindow(key: const ValueKey('chatWindow'))
            : _buildChatBubble(key: const ValueKey('chatBubble')),
      ),
    );
  }

  /// Builds the small floating bubble that appears when the chat is closed.
  Widget _buildChatBubble({Key? key}) {
    return GestureDetector(
      key: key,
      onTap: () => setState(() => _isChatOpen = true),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: vintageActiveIconColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 32),
      ),
    );
  }

  /// Builds the full chat window that opens when the bubble is tapped.
  Widget _buildChatWindow({Key? key}) {
    return Material(
      key: key,
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 320,
        height: 420,
        decoration: BoxDecoration(
          color: vintageCream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: vintageActiveIconColor, width: 1.5),
        ),
        child: Column(
          children: [
            // Header with a title and close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: vintageActiveIconColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)), // Adjusted for border
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Chat",
                    style: GoogleFonts.ebGaramond(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _isChatOpen = false),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            // Chat content placeholder
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "How can I help you?",
                    style: GoogleFonts.ebGaramond(
                      color: vintageDarkBrown,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            // Input area for typing messages
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.ebGaramond(color: vintageDarkBrown),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: GoogleFonts.ebGaramond(color: vintageDarkBrown.withOpacity(0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: vintageBorderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: vintageActiveIconColor, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: vintageActiveIconColor),
                    onPressed: () {
                      // Add send logic here
                      print("Message sent!");
                    },
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}