import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class BookBuddyApp extends StatelessWidget {
  const BookBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book Buddy',
      theme: ThemeData(
        // Use a font that matches the UI for a cleaner look
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const BookBuddyHomePage(),
    );
  }
}

// Main page widget holding the entire layout
class BookBuddyHomePage extends StatelessWidget {
  const BookBuddyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Header
          const Header(),
          // Main Body
          Expanded(
            child: Row(
              children: [
                const LeftSidebar(),
                const MainContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 1. Header Widget
class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: const Color(0xFFF7F8FA), // Light background for the header area
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: Colors.purple, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Book Buddy',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Your AI Reading Companion',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const Spacer(),
          const StatusChip(isConnected: false),
        ],
      ),
    );
  }
}

// 2. Left Sidebar Widget
class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      color: const Color(0xFFF7F8FA),
      padding: const EdgeInsets.all(24.0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UploadBookCard(),
          SizedBox(height: 24),
          QuickStartCard(),
          SizedBox(height: 24),
          FeaturesCard(),
        ],
      ),
    );
  }
}

// 2a. "Upload Book" Card
class UploadBookCard extends StatelessWidget {
  const UploadBookCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.upload_file_outlined, color: Colors.purple),
                SizedBox(width: 8),
                Text('Upload Book', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {}, // Action for choosing file
              borderRadius: BorderRadius.circular(8),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8A2BE2), Color(0xFFC77DFF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Choose PDF File',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2b. "Quick Start" Card
class QuickStartCard extends StatelessWidget {
  const QuickStartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star_outline, color: Colors.orange),
                SizedBox(width: 8),
                Text('Quick Start', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            QuickStartButton(text: "What's this book about?"),
            const SizedBox(height: 8),
            QuickStartButton(text: "Who are the main characters?"),
            const SizedBox(height: 8),
            QuickStartButton(text: "What are the key themes?"),
            const SizedBox(height: 8),
            QuickStartButton(text: "Summarize the plot"),
          ],
        ),
      ),
    );
  }
}

// 2c. "Features" Card
class FeaturesCard extends StatelessWidget {
  const FeaturesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite_border, color: Colors.pink),
                SizedBox(width: 8),
                Text('Features', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            FeatureItem(
                icon: Icons.chat_bubble_outline, text: 'Real-time chat'),
            SizedBox(height: 12),
            FeatureItem(icon: Icons.menu_book, text: 'Deep book analysis'),
            SizedBox(height: 12),
            FeatureItem(icon: Icons.flash_on, text: 'Instant responses'),
            SizedBox(height: 12),
            FeatureItem(
                icon: Icons.auto_awesome_outlined, text: 'AI-powered insights'),
          ],
        ),
      ),
    );
  }
}


// 3. Main Content Area
class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F6FF), Color(0xFFE9EAFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // This Expanded makes the welcome message take up all available space
            const Expanded(
              child: SingleChildScrollView(
                child: WelcomeSection(),
              ),
            ),
            // The chat input area at the bottom
            const ChatInputArea(),
          ],
        ),
      ),
    );
  }
}

// 3a. Welcome Section in the middle of MainContent
class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFC77DFF),
              gradient: LinearGradient(
                  colors: [Color(0xFF8A2BE2), Color(0xFFC77DFF)]),
            ),
            child: const Icon(Icons.menu_book_outlined,
                color: Colors.white, size: 48),
          ),
          const SizedBox(height: 24),
          const Text(
            'Welcome to Book Buddy!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Upload a PDF book and start having engaging conversations\nabout literature, characters, themes, and more with your AI\nreading companion.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: const [
              SuggestionChip(
                  icon: Icons.biotech_outlined, text: 'Literature Analysis'),
              SuggestionChip(
                  icon: Icons.person_outline, text: 'Character Study'),
              SuggestionChip(
                  icon: Icons.explore_outlined, text: 'Theme Exploration'),
              SuggestionChip(
                  icon: Icons.auto_stories_outlined, text: 'Plot Discussion'),
            ],
          )
        ],
      ),
    );
  }
}

// 3b. Chat Input Area at the bottom of MainContent
class ChatInputArea extends StatelessWidget {
  const ChatInputArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                  )
                ]),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ask me anything about your book...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {}, // Send action
                    borderRadius: BorderRadius.circular(8),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8A2BE2), Color(0xFFC77DFF)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child:
                            Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Press Enter to send, Shift+Enter for new line',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const StatusChip(isConnected: false),
            ],
          )
        ],
      ),
    );
  }
}


// --- Reusable Helper Widgets ---

// Helper for "Disconnected/Connected" chip
class StatusChip extends StatelessWidget {
  final bool isConnected;
  const StatusChip({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle,
              color: isConnected ? Colors.green : Colors.red, size: 8),
          const SizedBox(width: 6),
          Text(
            isConnected ? 'Connected' : 'Disconnected',
            style: TextStyle(
              color: isConnected ? Colors.green[800] : Colors.red[800],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper for Quick Start prompt buttons
class QuickStartButton extends StatelessWidget {
  final String text;
  const QuickStartButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        backgroundColor: Colors.purple.withOpacity(0.05),
        foregroundColor: Colors.purple[800],
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.centerLeft,
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.normal)),
    );
  }
}

// Helper for listed features with an icon
class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }
}

// Helper for suggestion chips in the welcome area
class SuggestionChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const SuggestionChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(icon, size: 18, color: Colors.purple[800]),
      label: Text(text, style: TextStyle(color: Colors.purple[800])),
      onPressed: () {},
      style: TextButton.styleFrom(
        backgroundColor: Colors.purple.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}