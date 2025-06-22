import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'dart:ui' as ui; // Explicitly import for ImageFilter

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

// --- NEW MODERN COLOR PALETTE ---
// This palette combines a sophisticated dark theme with a vibrant, modern accent.
const Color darkPrimary = Color(0xFF1E1E2C); // Deep space blue
const Color darkSecondary = Color(0xFF27293D); // Slightly lighter for cards
const Color accentColor = Color(0xFF00BFA6); // Vibrant teal/aqua
const Color accentHoverColor = Color(0xFF00A794);
const Color textPrimary = Color(0xFFF0F0F0); // Soft, parchment-like white
const Color textSecondary = Color(0xFFB0B0C0);
const Color errorColor = Color(0xFFFF5252);
const Color userBubbleColor = accentColor;
const Color botBubbleColor = Color(0xFF373A53);

// Light Theme (Optional but good practice)
const Color lightPrimary = Color(0xFFF5F5FA);
const Color lightSecondary = Color(0xFFFFFFFF);
const Color lightTextPrimary = Color(0xFF1E1E1E);

class Chatapp extends StatefulWidget {
  const Chatapp({super.key});

  @override
  State<Chatapp> createState() => _ChatappState();
}

class _ChatappState extends State<Chatapp> with SingleTickerProviderStateMixin {
  final String chatUrl = dotenv.env['chatUrl']!;

  PdfControllerPinch? _pdfController;
  String? _pdfFilename;

  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  bool _isConnected = false;
  bool _isTyping = false;
  bool _isUploading = false;
  String _uploadStatus = '';
  String? _sessionId;

  bool _isChatExpanded = false;
  late AnimationController _animationController;

  bool _isDarkTheme = true;

  // --- No changes needed in the logic ---
  Future<void> _initializeSession() async {
    try {
      final response = await http.post(
        Uri.parse('${chatUrl}/api/sessions'),
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      if (!mounted) return; // <-- Add this line
      setState(() {
        _sessionId = data['session_id'];
        _isConnected = true;
      });
    } catch (e) {
      if (!mounted) return; // <-- Add this line
      setState(() {
        _messages.add({
          'role': 'system',
          'content': 'Failed to create session: $e',
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
    }
  }

  Future<void> _pickPDF() async {
    if (_sessionId == null) return;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _isUploading = true;
        _uploadStatus = 'Processing document...';
      });

      final fileBytes = result.files.single.bytes!;
      final fileName = result.files.single.name;
      final uri = Uri.parse('${chatUrl}/api/sessions/$_sessionId/upload');

      try {
        var request = http.MultipartRequest('POST', uri);
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: fileName,
            contentType: MediaType('application', 'pdf'),
          ),
        );
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          _pdfController?.dispose();
          setState(() {
            _pdfFilename = fileName;
            _pdfController = PdfControllerPinch(
              document: PdfDocument.openData(fileBytes),
            );
            _isUploading = false;
            _uploadStatus = 'Successfully loaded $fileName';
            _toggleChatPanel(expand: true);
          });
        } else {
          setState(() {
            _isUploading = false;
            _uploadStatus = 'Upload failed: ${response.body}';
          });
        }
      } catch (e) {
        setState(() {
          _isUploading = false;
          _uploadStatus = 'Upload failed: $e';
        });
      }
    }
  }

  void _sendMessage() async {
    if (_chatController.text.trim().isEmpty || !_isConnected) return;
    final messageText = _chatController.text.trim();
    setState(() {
      _messages.add({
        'role': 'user',
        'content': messageText,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _chatController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    if (_sessionId == null) return;
    try {
      final response = await http.post(
        Uri.parse('${chatUrl}/api/sessions/$_sessionId/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': messageText}),
      );
      print('Chat response: ${response.body}');

      // Fetch updated messages after sending
      await _fetchMessages();
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'system',
          'content': 'Failed to send message: $e',
          'timestamp': DateTime.now().toIso8601String(),
        });
        _isTyping = false;
      });
    }
  }

  Future<void> _fetchMessages() async {
    if (_sessionId == null) return;
    try {
      final response = await http.get(
        Uri.parse('${chatUrl}/api/sessions/$_sessionId/messages'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          // If data is a list of messages
          if (data is List) {
            _messages
              ..clear()
              ..addAll(data.cast<Map<String, dynamic>>());
          } else if (data is Map && data.containsKey('messages')) {
            // If backend returns { "messages": [...] }
            _messages
              ..clear()
              ..addAll((data['messages'] as List).cast<Map<String, dynamic>>());
          } else if (data is Map &&
              data.containsKey('role') &&
              data.containsKey('content')) {
            // If backend returns a single message
            _messages.add(data as Map<String, dynamic>);
          }
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _isTyping = false;
      });
    }
  }
  // --- end of logic section ---

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _initializeSession();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _toggleChatPanel({bool? expand}) {
    setState(() {
      _isChatExpanded = expand ?? !_isChatExpanded;
      if (_isChatExpanded) {
        _animationController.forward(from: 0);
      } else {
        _animationController.reverse(from: 1);
      }
    });
  }

  // --- NEW & ENHANCED WIDGETS ---

  // Build a stylish message bubble
  Widget _buildMessage(Map<String, dynamic> message, {bool isMobile = false}) {
    final bool isUser = message['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: isMobile ? 3 : 6,
          horizontal: isMobile ? 2 : 4,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 16,
          vertical: isMobile ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: isUser ? userBubbleColor : botBubbleColor,
          borderRadius: BorderRadius.circular(isMobile ? 12 : 20).subtract(
            isUser
                ? BorderRadius.only(
                  bottomRight: Radius.circular(isMobile ? 8 : 16),
                )
                : BorderRadius.only(
                  bottomLeft: Radius.circular(isMobile ? 8 : 16),
                ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: isMobile ? 4 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message['content'] ?? '',
          style:
              isUser
                  ? GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 13 : 15,
                  )
                  : GoogleFonts.lora(
                    color: textPrimary,
                    fontSize: isMobile ? 13.5 : 16,
                    fontWeight: FontWeight.w500,
                  ),
        ),
      ),
    );
  }

  // A glassmorphic chat overlay that blurs the content behind it
  Widget _buildChatOverlay() {
    final isMobile = MediaQuery.of(context).size.width < 500;
    final double overlayWidth =
        isMobile
            ? MediaQuery.of(context).size.width - 16
            : (_isChatExpanded ? 420 : 80);
    final double overlayHeight =
        isMobile
            ? (_isChatExpanded ? MediaQuery.of(context).size.height * 0.85 : 64)
            : (_isChatExpanded
                ? MediaQuery.of(context).size.height * 0.75
                : 80);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      width: overlayWidth,
      height: overlayHeight,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - (isMobile ? 40 : 100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color:
                  _isDarkTheme
                      ? darkSecondary.withOpacity(0.85)
                      : lightSecondary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(isMobile ? 12 : 24),
              border: Border.all(color: textPrimary.withOpacity(0.1)),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child:
                  _isChatExpanded
                      ? _buildExpandedChat(isMobile: isMobile)
                      : _buildCollapsedChat(isMobile: isMobile),
            ),
          ),
        ),
      ),
    );
  }

  // Collapsed state of the chat bubble icon
  Widget _buildCollapsedChat({bool isMobile = false}) {
    return InkWell(
      key: const ValueKey('collapsed'),
      onTap: () => _toggleChatPanel(expand: true),
      borderRadius: BorderRadius.circular(isMobile ? 12 : 24),
      child: Center(
        child: ShaderMask(
          shaderCallback:
              (bounds) => const LinearGradient(
                colors: [accentColor, Color(0xFF00E0C4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
          child: Icon(
            Icons.mark_unread_chat_alt_rounded,
            color: Colors.white,
            size: isMobile ? 32 : 44,
          ),
        ),
      ),
    );
  }

  // Expanded state of the chat panel
  Widget _buildExpandedChat({bool isMobile = false}) {
    return Column(
      key: const ValueKey('expanded'),
      children: [
        InkWell(
          onTap: () => _toggleChatPanel(expand: false),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 12 : 24,
              isMobile ? 10 : 20,
              isMobile ? 8 : 16,
              isMobile ? 8 : 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Book Buddy",
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: isMobile ? 16 : 22,
                    color: _isDarkTheme ? textPrimary : lightTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RotationTransition(
                  turns: Tween(
                    begin: 0.0,
                    end: 0.5,
                  ).animate(_animationController),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _isDarkTheme ? textSecondary : Colors.grey.shade600,
                    size: isMobile ? 24 : 32,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
            itemCount: _messages.length,
            itemBuilder:
                (context, index) =>
                    _buildMessage(_messages[index], isMobile: isMobile),
          ),
        ),
        if (_isTyping) const TypingIndicator(),
        Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 8 : 16,
            8,
            isMobile ? 8 : 16,
            isMobile ? 10 : 20,
          ),
          child: _buildChatInputField(isMobile: isMobile),
        ),
      ],
    );
  }

  // The chat text field and send button
  Widget _buildChatInputField({bool isMobile = false}) {
    return Container(
      decoration: BoxDecoration(
        color: (_isDarkTheme ? Colors.black : Colors.white).withOpacity(0.2),
        borderRadius: BorderRadius.circular(isMobile ? 18 : 25),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              style: GoogleFonts.inter(
                color: textPrimary,
                fontSize: isMobile ? 13.5 : 15,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 20,
                ),
                hintText: 'Ask your Buddy a question...',
                hintStyle: GoogleFonts.inter(
                  color: textSecondary,
                  fontSize: isMobile ? 13 : 15,
                ),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 2.0 : 4.0),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: accentColor,
                hoverColor: accentHoverColor,
                shape: const CircleBorder(),
                padding: EdgeInsets.all(isMobile ? 8 : 12),
              ),
              icon: Icon(
                Icons.send_rounded,
                color: Colors.black,
                size: isMobile ? 18 : 22,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  // Widget for initial upload screen
  Widget _buildInitialUploadView() {
    final isMobile = MediaQuery.of(context).size.width < 500;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Load a Book to Begin Your Journey',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: isMobile ? 20 : 32,
              fontWeight: FontWeight.w700,
              color: textSecondary,
            ),
          ),
          SizedBox(height: isMobile ? 24 : 40),
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _pickPDF,
            icon:
                _isUploading
                    ? SizedBox(
                      width: isMobile ? 16 : 20,
                      height: isMobile ? 16 : 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: darkPrimary,
                      ),
                    )
                    : Icon(Icons.menu_book_rounded, size: isMobile ? 18 : 24),
            label: Text(
              _isUploading ? 'ANALYZING...' : 'LOAD EBOOK',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: isMobile ? 13.5 : 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: darkPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 18 : 32,
                vertical: isMobile ? 12 : 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isMobile ? 10 : 16),
              ),
              textStyle: TextStyle(fontSize: isMobile ? 13.5 : 16),
            ),
          ),
          if (_uploadStatus.isNotEmpty && !_isUploading)
            Padding(
              padding: EdgeInsets.only(top: isMobile ? 12 : 24),
              child: Text(
                _uploadStatus,
                style: TextStyle(
                  color: errorColor,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget to display the PDF with controls
  Widget _buildPdfView() {
    final isMobile = MediaQuery.of(context).size.width < 500;
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(bottom: isMobile ? 8 : 16),
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickPDF,
              icon: Icon(Icons.upload_file_rounded, size: isMobile ? 14 : 18),
              label: Text(
                'Load Another',
                style: TextStyle(fontSize: isMobile ? 13 : 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkSecondary,
                foregroundColor: textPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 18,
                  vertical: isMobile ? 8 : 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                ),
                textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: isMobile ? 10 : 30,
                        spreadRadius: isMobile ? 2 : 5,
                      ),
                    ],
                  ),
                  child: PdfViewPinch(
                    key: ValueKey(_pdfFilename),
                    controller: _pdfController!,
                    padding: 0,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _pdfController!.pageListenable,
                    builder: (context, pageNumber, child) {
                      final totalPages = _pdfController!.pagesCount;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(isMobile ? 10 : 20),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            margin: EdgeInsets.only(bottom: isMobile ? 10 : 20),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 8 : 16,
                              vertical: isMobile ? 4 : 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(
                                isMobile ? 10 : 20,
                              ),
                            ),
                            child: Text(
                              'Page $pageNumber of $totalPages',
                              style: GoogleFonts.inter(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 11.5 : 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    final horizontalPad = isMobile ? 4.0 : 48.0;
    final verticalPad = isMobile ? 4.0 : 24.0;

    // --- Define professional themes ---
    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkPrimary,
      primaryColor: accentColor,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: accentColor,
        background: darkPrimary,
        surface: darkSecondary,
        error: errorColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkPrimary.withOpacity(
          0.8,
        ), // Semi-transparent for depth
        foregroundColor: textPrimary,
        elevation: 0, // Let the content create the depth
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      iconTheme: const IconThemeData(color: textSecondary),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    final ThemeData lightTheme = ThemeData(
      // Basic light theme as a fallback
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightPrimary,
      primaryColor: accentColor,
      colorScheme: const ColorScheme.light(
        primary: accentColor,
        secondary: accentColor,
        background: lightPrimary,
        surface: lightSecondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSecondary,
        foregroundColor: lightTextPrimary,
        elevation: 1,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
      ),
    );

    return Theme(
      data: _isDarkTheme ? darkTheme : lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _pdfFilename ?? "eBook Reader AI",
            style: TextStyle(fontSize: isMobile ? 16 : 20),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isDarkTheme ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                size: isMobile ? 20 : 28,
              ),
              tooltip:
                  _isDarkTheme ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              onPressed: () {
                setState(() {
                  _isDarkTheme = !_isDarkTheme;
                });
              },
            ),
            SizedBox(width: isMobile ? 2 : 8),
          ],
        ),
        body: Stack(
          children: [
            // Center PDF content with padding
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: verticalPad,
                  bottom: verticalPad,
                  left: horizontalPad,
                  right: horizontalPad,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isMobile ? 600 : 1100),
                  child:
                      _pdfController == null
                          ? _buildInitialUploadView()
                          : _buildPdfView(),
                ),
              ),
            ),
            // Positioned glassmorphic chat panel
            if (_pdfFilename != null && !_isUploading)
              Positioned(
                bottom: isMobile ? 8 : 24,
                right: isMobile ? 8 : 24,
                child: _buildChatOverlay(),
              ),
          ],
        ),
      ),
    );
  }
}

// --- NEW ANIMATED TYPING INDICATOR WIDGET ---
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildDot(0),
          const SizedBox(width: 8),
          _buildDot(1),
          const SizedBox(width: 8),
          _buildDot(2),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final double begin = index * 0.2;
    final double end = begin + 0.4;
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(begin, end, curve: Curves.easeInOut),
        ),
      ),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: accentColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
