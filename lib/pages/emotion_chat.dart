// lib/widgets/chat_widget.dart
import 'dart:convert';
import 'package:bookrec/theme/color.dart'; // Your color definitions
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ChatWidget extends StatefulWidget {
  const ChatWidget({Key? key}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  bool _isChatOpen = false;
  String? _sessionId;

  final String baseUrl = 'http://localhost:5000';
  final String chatApiBaseUrl = 'http://localhost:5000';

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages =
      []; // {'role': 'user'/'bot', 'text': ...}
  bool _isSending = false;

  Future<void> _initializeSession() async {
    final url = Uri.parse('$baseUrl/emotion/api/sessions');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _sessionId = data['session_id'];
        });
        print('Session initialized: $_sessionId');
      } else {
        print('Failed to initialize session: ${response.statusCode}');
      }
    } catch (e) {
      print('Error initializing session: $e');
    }
  }

  Future<void> _sendMessage(String message) async {
    if (_sessionId == null || message.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': message});
      _isSending = true;
    });
    final url = Uri.parse(
      '$chatApiBaseUrl/emotion/api/sessions/$_sessionId/chat',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages.add({
            'role': 'bot',
            'text': data['response'] ?? 'No response.',
          });
        });
      } else {
        setState(() {
          _messages.add({
            'role': 'bot',
            'text': 'Error: ${response.statusCode}',
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'text': 'Error sending message.'});
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _openChat() {
    setState(() {
      _isChatOpen = true;
    });
    if (_sessionId == null) {
      _initializeSession();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32,
      right: 32,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(child: child, scale: animation);
        },
        child:
            _isChatOpen
                ? _buildChatWindow(key: const ValueKey('chatWindow'))
                : _buildChatBubble(key: const ValueKey('chatBubble')),
      ),
    );
  }

  Widget _buildChatBubble({Key? key}) {
    return GestureDetector(
      key: key,
      onTap: _openChat,
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
        child: const Icon(
          Icons.chat_bubble_outline,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

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
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: vintageActiveIconColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
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
            // Chat content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child:
                    _messages.isEmpty
                        ? Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "How can I help you?",
                            style: GoogleFonts.ebGaramond(
                              color: vintageDarkBrown,
                              fontSize: 16,
                            ),
                          ),
                        )
                        : ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isUser = msg['role'] == 'user';
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              alignment:
                                  isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      isUser
                                          ? vintageActiveIconColor.withOpacity(
                                            0.8,
                                          )
                                          : vintageCream,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        isUser
                                            ? vintageActiveIconColor
                                            : vintageBorderColor,
                                  ),
                                ),
                                child: Text(
                                  msg['text'] ?? '',
                                  style: GoogleFonts.ebGaramond(
                                    color:
                                        isUser
                                            ? Colors.white
                                            : vintageDarkBrown,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
            // Input area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.ebGaramond(color: vintageDarkBrown),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: GoogleFonts.ebGaramond(
                          color: vintageDarkBrown.withOpacity(0.6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: vintageBorderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: vintageActiveIconColor,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                      onSubmitted: (value) {
                        if (!_isSending) {
                          _sendMessage(value);
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: vintageActiveIconColor),
                    onPressed:
                        _isSending
                            ? null
                            : () {
                              final text = _controller.text.trim();
                              if (text.isNotEmpty) {
                                _sendMessage(text);
                                _controller.clear();
                              }
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
