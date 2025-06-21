// lib/widgets/chat_widget.dart
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

// Let's define a new, modern color palette right here for clarity.
const Color kModernDarkBlue = Color(0xFF1C1B2B);
const Color kModernPurple = Color(0xFF9F7AEA);
const Color kModernBlue = Color(0xFF5A67D8);
const Color kModernGray = Color(0xFF323040);
const Color kModernLightGray = Color(0xFF817E9B);

class ChatWidget extends StatefulWidget {
  const ChatWidget({Key? key}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  bool _isChatOpen = false;
  String? _sessionId;

  final String baseUrl =
      'http://localhost:5000'; // Replace with your backend URL
  final String chatApiBaseUrl =
      'http://localhost:5000'; // Replace with your backend URL

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // The 'messages' list now supports different types for custom widgets
  final List<Map<String, dynamic>> _messages = [];
  bool _isSending = false;
  int _userMessageCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom([double extra = 0.0]) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + extra,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _initializeSession() async {
    _addMessage('bot', text: 'Connecting to my library...');
    final url = Uri.parse('$baseUrl/emotion/api/sessions');
    try {
      final response = await http.post(url);
      // Remove the "Connecting..." message
      if (_messages.isNotEmpty) {
        _messages.removeLast();
        _listKey.currentState?.removeItem(
          _messages.length,
          (context, animation) => const SizedBox.shrink(),
        );
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _sessionId = data['session_id']);
        _addMessage(
          'bot',
          text:
              'Hi! I\'m Lumina, your AI book scout. Tell me about a book you loved or how you\'re feeling today!',
        );
      } else {
        _addMessage(
          'bot',
          text:
              'I couldn\'t establish a connection. Please try opening the chat again.',
        );
      }
    } catch (e) {
      if (_messages.isNotEmpty) {
        _messages.removeLast();
        _listKey.currentState?.removeItem(
          _messages.length,
          (context, animation) => const SizedBox.shrink(),
        );
      }
      _addMessage(
        'bot',
        text:
            'Oops! My circuits are tangled. Please check the connection and try again.',
      );
    }
  }

  Future<void> _sendMessage(String message) async {
    if (_sessionId == null || message.trim().isEmpty || _isSending) return;

    HapticFeedback.lightImpact();
    setState(() => _isSending = true);

    final userMessage = message.trim();
    _controller.clear();
    _addMessage('user', text: userMessage);
    _scrollToBottom(50);

    final url = Uri.parse(
      '$chatApiBaseUrl/emotion/api/sessions/$_sessionId/chat',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': userMessage}),
      );
      setState(() => _isSending = false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _addMessage('bot', text: data['response'] ?? 'No response.');
      } else {
        _addMessage('bot', text: 'Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isSending = false);
      _addMessage('bot', text: 'Error sending message.');
    }

    _userMessageCount++;
    // Fetch recommendations every 5 user messages
    if (_userMessageCount % 5 == 0) {
      _fetchRecommendations();
    }
    _scrollToBottom();
  }

  Future<void> _fetchRecommendations() async {
    if (_sessionId == null) return;
    setState(() => _isSending = true);
    _addMessage('bot', text: 'Let me think...');
    _scrollToBottom();

    final url = Uri.parse(
      '$baseUrl/emotion/api/sessions/$_sessionId/recommendations',
    );
    try {
      final response = await http.get(url);
      print('response status: ${response.statusCode}');
      print('response body: ${response.body}');
      // Remove the 'Let me think...' bubble
      if (_messages.isNotEmpty) {
        final thinkingIndex = _messages.length - 1;
        _messages.removeAt(thinkingIndex);
        _listKey.currentState?.removeItem(
          thinkingIndex,
          (context, animation) => const SizedBox.shrink(),
        );
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List recs = data['recommendations'] ?? [];
        if (recs.isNotEmpty) {
          _addMessage(
            'bot',
            text: 'Based on our chat, I found a few gems for you!',
          );
          for (var rec in recs) {
            _addMessage('bot', type: 'recommendation', data: rec);
            await Future.delayed(const Duration(milliseconds: 200));
          }
        } else {
          _addMessage('bot', text: 'No recommendations found.');
        }
      } else {
        _addMessage('bot', text: 'Error fetching recommendations.');
      }
    } catch (e) {
      _addMessage('bot', text: 'Error fetching recommendations.');
    }
    setState(() => _isSending = false);
    _scrollToBottom(300);
  }

  void _addMessage(
    String role, {
    String? text,
    String type = 'text',
    Map<String, dynamic>? data,
  }) {
    final message = {'role': role, 'type': type, 'text': text, 'data': data};
    final index = _messages.length;
    _messages.add(message);
    _listKey.currentState?.insertItem(
      index,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _toggleChat(bool open) {
    HapticFeedback.mediumImpact();
    setState(() => _isChatOpen = open);
    if (open && _sessionId == null) {
      _messages.clear(); // Clear old messages
      _initializeSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOutQuart,
        switchOutCurve: Curves.easeInOutQuart,
        transitionBuilder:
            (child, animation) =>
                ScaleTransition(scale: animation, child: child),
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
      onTap: () => _toggleChat(true),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [kModernBlue, kModernPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: kModernPurple.withOpacity(0.5),
              blurRadius: 16,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.psychology_outlined,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildChatWindow({Key? key}) {
    return Container(
      key: key,
      width: 360,
      height: 600,
      clipBehavior: Clip.antiAlias, // Important for child border radius
      decoration: BoxDecoration(
        color: kModernDarkBlue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [_buildChatHeader(), _buildMessageList(), _buildInputArea()],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          Text(
            "Lumina AI",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
            ),
          ),
          const Spacer(),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
            icon: const Icon(Icons.close, color: kModernLightGray, size: 20),
            onPressed: () => _toggleChat(false),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Expanded(
      child: AnimatedList(
        key: _listKey,
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        initialItemCount: _messages.length,
        itemBuilder: (context, index, animation) {
          final msg = _messages[index];

          Widget child;
          if (msg['type'] == 'recommendation') {
            final data = msg['data'] ?? {};
            child = _BookRecommendationCard(
              title: data['title']?.toString() ?? 'Unknown Title',
              author: data['author']?.toString() ?? 'Unknown Author',
              description: data['description']?.toString() ?? 'No description.',
              onTap: () {
                // Here you would navigate to a book details page
                print("Tapped on ${data['title'] ?? 'Unknown Title'}");
                HapticFeedback.lightImpact();
              },
            );
          } else {
            child = _MessageBubble(
              message: msg['text'] ?? '',
              isUser: msg['role'] == 'user',
              isThinking: msg['text'] == 'Let me think...',
            );
          }

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Material(
        color: Colors.transparent,
        child: TextField(
          controller: _controller,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: kModernGray,
            hintText: "Ask for a recommendation...",
            hintStyle: GoogleFonts.inter(color: kModernLightGray),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon:
                    _isSending
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kModernPurple,
                          ),
                        )
                        : const Icon(Icons.send_rounded, color: kModernPurple),
                onPressed: () => _sendMessage(_controller.text),
              ),
            ),
          ),
          onSubmitted: _sendMessage,
        ),
      ),
    );
  }
}

// --- WIDGETS FOR CLEANLINESS --- //

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isThinking;

  const _MessageBubble({
    Key? key,
    required this.message,
    required this.isUser,
    this.isThinking = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          gradient:
              isUser
                  ? const LinearGradient(colors: [kModernBlue, kModernPurple])
                  : null,
          color: isUser ? null : kModernGray,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight:
                isUser ? const Radius.circular(4) : const Radius.circular(18),
            bottomLeft:
                isUser ? const Radius.circular(18) : const Radius.circular(4),
          ),
        ),
        child:
            isThinking
                ? const _TypingIndicator()
                : Text(
                  message,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator({Key? key}) : super(key: key);

  @override
  __TypingIndicatorState createState() => __TypingIndicatorState();
}

class __TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return ScaleTransition(
            scale: DelayTween(begin: 0.2, end: 1.0, delay: i * 0.2).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BookRecommendationCard extends StatelessWidget {
  final String title;
  final String author;
  final String description;
  final VoidCallback onTap;

  const _BookRecommendationCard({
    Key? key,
    required this.title,
    required this.author,
    required this.description,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kModernGray,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: kModernPurple.withOpacity(0.3),
        highlightColor: kModernPurple.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover Placeholder
              Container(
                width: 70,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      kModernBlue.withOpacity(0.5),
                      kModernPurple.withOpacity(0.5),
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: const Icon(
                  Icons.book_online_rounded,
                  color: Colors.white70,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              // Book Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by $author',
                      style: GoogleFonts.inter(
                        color: kModernLightGray,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A helper class for the typing indicator animation
class DelayTween extends Tween<double> {
  final double delay;

  DelayTween({double? begin, double? end, required this.delay})
    : super(begin: begin, end: end);

  @override
  double lerp(double t) {
    return super.lerp((t - delay).clamp(0.0, 1.0));
  }
}
