import 'dart:math';
import 'package:bookrec/provider/authprovider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:bookrec/services/booksapi.dart'; // Add this import

// --- MAIN WIDGET: THE PROJECT SHOWCASE PAGE ---
class BookProjectShowcasePage extends StatefulWidget {
  const BookProjectShowcasePage({super.key});

  @override
  State<BookProjectShowcasePage> createState() =>
      _BookProjectShowcasePageState();
}

class _BookProjectShowcasePageState extends State<BookProjectShowcasePage> {
  final ScrollController _scrollController = ScrollController();

  // Vibrant & diverse color palette for a feature-rich showcase
  static const Color parchment = Color(0xFFFBF5E9);
  static const Color ink = Color(0xFF2C2B27);
  static const Color warmAccent = Color(0xFFC97B63);
  static const Color coolAccent = Color(
    0xFF5C6B73,
  ); // For blueprint/tech sections
  static const Color vibrantGreen = Color(0xFF3C8A7D);
  static const Color deepPurple = Color(0xFF594A65);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: parchment,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://www.transparenttextures.com/patterns/old-paper.png',
                ),
                repeat: ImageRepeat.repeat,
                opacity: 0.3,
              ),
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _HeroSection(),
                _TrendingBooksSection(),
                _CoreFeaturesShowcase(),
                const SizedBox(height: 120),
                _TechArchitectureSection(),
                _FinalCtaSection(),
                _FooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- FEATURE-FOCUSED SECTIONS ---

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ProviderUser = Provider.of<UserProvider>(context);

    return Container(
      height: 600,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _FloatingIcon(
            icon: Icons.search,
            top: 50,
            left: 100,
            rotation: -0.2,
            speed: 0.2,
          ),
          _FloatingIcon(
            icon: Icons.thumb_up_alt_outlined,
            top: 150,
            right: 80,
            rotation: 0.3,
            speed: 0.35,
          ),
          _FloatingIcon(
            icon: Icons.devices,
            bottom: 80,
            left: 150,
            rotation: 0.1,
            speed: 0.25,
          ),
          _FloatingIcon(
            icon: Icons.picture_as_pdf_outlined,
            bottom: 120,
            right: 180,
            rotation: -0.1,
            speed: 0.3,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Books & Recs",
                style: GoogleFonts.caveat(
                  fontSize: 72,
                  fontWeight: FontWeight.w700,
                  color: _BookProjectShowcasePageState.ink,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "A Modern Reader's Toolkit.",
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                  color: _BookProjectShowcasePageState.ink.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 30),
              _InkButton(
                text: "Explore the Project",
                onPressed: () {
                  if (ProviderUser.getToken == '') {
                    context.push('/signin');
                  } else {
                    context.push('/dashboard/home');
                  }
                },
                isLarge: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendingBooksSection extends StatefulWidget {
  @override
  State<_TrendingBooksSection> createState() => _TrendingBooksSectionState();
}

class _TrendingBooksSectionState extends State<_TrendingBooksSection> {
  late Future<List> _trendingBooksFuture;

  @override
  void initState() {
    super.initState();
    _trendingBooksFuture = BooksInfo().getTrendingBooks();
  }

  @override
  Widget build(BuildContext context) {
    final ProviderUser = Provider.of<UserProvider>(context);
    return Column(
      children: [
        _SectionHeader(title: "Explore Trending Books"),
        const Text(
          "Fetched from our custom API endpoint",
          style: TextStyle(color: _BookProjectShowcasePageState.coolAccent),
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 280,
          child: FutureBuilder<List>(
            future: _trendingBooksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error loading trending books"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No trending books found."));
              }
              final books = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return GestureDetector(
                    onTap: () {
                      if (ProviderUser.getToken == '') {
                        context.push('/signin');
                      } else {
                        context.push(
                          '/book/${book['isbn10']}/${Uri.encodeComponent(book['title'] ?? 'Unknown')}',
                        );
                      }
                    },
                    child: _BookCoverCard(
                      imageUrl:
                          book['thumbnail'] ??
                          'https://via.placeholder.com/150x220?text=No+Cover',
                      title: book['title'] ?? 'Unknown',
                      rotation:
                          (index % 2 == 0 ? 1 : -1) * (0.01 * (index % 5)),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CoreFeaturesShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100),
      child: Column(
        children: [
          _SectionHeader(title: "Core Project Features"),
          const SizedBox(height: 80),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 32,
              runSpacing: 32,
              children: [
                SizedBox(
                  width: 320,
                  height: 320,

                  child: _ScrollFadeIn(child: _FeatureCard.search()),
                ),
                SizedBox(
                  width: 320,
                  height: 320,
                  child: _ScrollFadeIn(child: _FeatureCard.discussion()),
                ),
                SizedBox(
                  width: 320,
                  height: 320,
                  child: _ScrollFadeIn(child: _FeatureCard.crossPlatform()),
                ),
                SizedBox(
                  width: 320,
                  height: 320,
                  child: _ScrollFadeIn(child: _FeatureCard.pdfReader()),
                ),
                SizedBox(
                  width: 320,
                  height: 320,
                  child: _ScrollFadeIn(child: _FeatureCard.userAuth()),
                ),
                SizedBox(
                  width: 320,
                  height: 320,
                  child: _ScrollFadeIn(child: _FeatureCard.itemBased()),
                ),
                SizedBox(
                  width: 320,
                  height: 320,
                  child: _ScrollFadeIn(child: _FeatureCard.collaborative()),
                ),
                SizedBox(
                  width: 320,
                  height: 320,
                  child: _ScrollFadeIn(child: _FeatureCard.llm()),
                ),
                SizedBox(
                  width: 320,
                  height: 320,
                  child: _ScrollFadeIn(child: _FeatureCard.emotionBased()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionedFeature extends StatelessWidget {
  final Widget child;
  final double? top, bottom, left, right;
  final double rotation;
  const _PositionedFeature({
    required this.child,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: _ScrollFadeIn(
        delay: Duration(milliseconds: (200 + Random().nextInt(300))),
        child: Transform.rotate(angle: rotation, child: child),
      ),
    );
  }
}

class _TechArchitectureSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      decoration: BoxDecoration(
        color: _BookProjectShowcasePageState.coolAccent.withOpacity(0.95),
        image: const DecorationImage(
          image: NetworkImage(
            'https://www.transparenttextures.com/patterns/graphy.png',
          ),
          repeat: ImageRepeat.repeat,
          opacity: 0.2,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _ScrollFadeIn(
                child: Text(
                  "The Architecture",
                  style: GoogleFonts.lora(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _BookProjectShowcasePageState.parchment,
                  ),
                ),
              ),
              _ScrollFadeIn(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  "A look at the technologies powering this project",
                  style: GoogleFonts.lora(
                    color: _BookProjectShowcasePageState.parchment.withOpacity(
                      0.7,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _ScrollFadeIn(
                delay: const Duration(milliseconds: 400),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    _TechBubble("Flutter (Cross-Platform)"),
                    _TechBubble("Open Library API"),
                    _TechBubble("Custom REST API"),
                    _TechBubble("PDF.js Integration"),
                    _TechBubble("Token-based Auth"),
                    _TechBubble("Responsive Design"),
                    _TechBubble("Google Fonts"),
                    _TechBubble("Env-Based Config"),
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

class _FinalCtaSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
      child: Center(
        child: Column(
          children: [
            Text(
              "Ready to Dive In?",
              style: GoogleFonts.lora(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: _BookProjectShowcasePageState.ink,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Explore the live application or view the source code on GitHub.",
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontSize: 18,
                color: _BookProjectShowcasePageState.ink.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                _InkButton(
                  text: "View on GitHub",
                  onPressed: () {
                    final Uri _url = Uri.parse(
                      'https://github.com/Axkratos/Book-Recommendation.git',
                    );
                    // Use launchUrl from url_launcher to open the link
                    // Make sure to add url_launcher to your pubspec.yaml and import it
                    // import 'package:url_launcher/url_launcher.dart';
                    launchUrl(_url);
                  },
                  isLarge: true,
                  color: _BookProjectShowcasePageState.coolAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _BookProjectShowcasePageState.ink,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
      child: Center(
        child: Text(
          "© ${DateTime.now().year} Mohit Sir. Project for educational purposes.",
          style: GoogleFonts.lora(
            fontSize: 14,
            color: _BookProjectShowcasePageState.coolAccent,
          ),
        ),
      ),
    );
  }
}

// --- HELPER & DECORATIVE WIDGETS ---

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return _ScrollFadeIn(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.lora(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: _BookProjectShowcasePageState.warmAccent,
        ),
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  final double? top, bottom, left, right;
  final double rotation;
  final double speed;

  const _FloatingIcon({
    required this.icon,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.rotation,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: rotation,
        child: Icon(
          icon,
          size: 50,
          color: _BookProjectShowcasePageState.deepPurple.withOpacity(0.1),
        ),
      ),
    );
  }
}

class _InkButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLarge;
  final Color color;

  const _InkButton({
    required this.text,
    required this.onPressed,
    this.isLarge = false,
    this.color = _BookProjectShowcasePageState.warmAccent,
  });

  @override
  __InkButtonState createState() => __InkButtonState();
}

class __InkButtonState extends State<_InkButton> {
  bool _isHovering = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _isHovering ? -4 : 0, 0),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isLarge ? 32 : 28,
            vertical: widget.isLarge ? 16 : 14,
          ),
          decoration: BoxDecoration(
            color: _isHovering ? widget.color : Colors.transparent,
            border: Border.all(color: widget.color, width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow:
                _isHovering
                    ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ]
                    : [],
          ),
          child: Text(
            widget.text,
            style: GoogleFonts.lora(
              fontWeight: FontWeight.bold,
              fontSize: widget.isLarge ? 16 : 14,
              color:
                  _isHovering
                      ? (_BookProjectShowcasePageState.parchment)
                      : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookCoverCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final double rotation;
  const _BookCoverCard({
    required this.imageUrl,
    required this.title,
    this.rotation = 0,
  });

  @override
  __BookCoverCardState createState() => __BookCoverCardState();
}

class __BookCoverCardState extends State<_BookCoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform:
            Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_isHovered ? 0 : 0.2)
              ..rotateZ(widget.rotation)
              ..scale(_isHovered ? 1.05 : 1.0),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        width: 170,
        decoration: BoxDecoration(
          color: _BookProjectShowcasePageState.ink,
          image: DecorationImage(
            image: NetworkImage(widget.imageUrl),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.35 : 0.2),
              blurRadius: 20,
              offset: Offset(5, 5),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final Widget content;
  final Color borderColor;
  final IconData icon;

  const _FeatureCard({
    required this.title,
    required this.content,
    required this.icon,
    this.borderColor = _BookProjectShowcasePageState.warmAccent,
  });

  factory _FeatureCard.search() => _FeatureCard(
    title: "Live Book Search",
    icon: Icons.search,
    content: Column(
      children: [
        Text(
          "Uses the Open Library API to find books, authors, and ratings.",
          style: GoogleFonts.lora(),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: _BookProjectShowcasePageState.coolAccent.withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Dune...|",
                  style: TextStyle(color: _BookProjectShowcasePageState.ink),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  factory _FeatureCard.discussion() => _FeatureCard(
    title: "Discussion & Reviews",
    icon: Icons.reviews_outlined,
    borderColor: _BookProjectShowcasePageState.deepPurple,
    content: Column(
      children: [
        Text(
          "Users can comment, upvote, and use rich text formatting.",
          style: GoogleFonts.lora(),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black.withOpacity(0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  CircleAvatar(radius: 12),
                  SizedBox(width: 8),
                  Text("ElenaR", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.lora(
                    color: _BookProjectShowcasePageState.ink,
                  ),
                  children: const [
                    TextSpan(text: "That reveal was "),
                    TextSpan(
                      text: "amazing!",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: " But did anyone else notice the hint on page ",
                    ),
                    TextSpan(
                      text: "42?",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.arrow_upward_rounded,
                    color: _BookProjectShowcasePageState.vibrantGreen,
                    size: 20,
                  ),
                  Text(" 17", style: GoogleFonts.lora()),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  factory _FeatureCard.pdfReader() => _FeatureCard(
    title: "In-App PDF Reader",
    icon: Icons.picture_as_pdf,
    content: Column(
      children: [
        Text(
          "Utilizes PDF.js to render PDF documents directly in the browser for a seamless reading experience.",
          style: GoogleFonts.lora(),
        ),
        const SizedBox(height: 20),
        const Icon(
          Icons.chrome_reader_mode_outlined,
          size: 50,
          color: _BookProjectShowcasePageState.warmAccent,
        ),
      ],
    ),
  );

  factory _FeatureCard.crossPlatform() => _FeatureCard(
    title: "Cross-Platform Support",
    icon: Icons.devices,
    borderColor: _BookProjectShowcasePageState.vibrantGreen,
    content: Column(
      children: [
        Text(
          "Built with Flutter to ensure a consistent experience on Web, Windows, and Linux from a single codebase.",
          style: GoogleFonts.lora(),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(Icons.public, size: 30), // Web
            const Icon(Icons.desktop_windows, size: 30),
            const Icon(Icons.mobile_friendly, size: 30), // Linux
            // NOTE: Add a small linux logo to your assets folder
          ],
        ),
      ],
    ),
  );

  factory _FeatureCard.userAuth() => _FeatureCard(
    title: "Token-Based Authentication",
    icon: Icons.security,
    content: Column(
      children: [
        Text(
          "Secure user authentication allows for personalized experiences like saving reviews and discussion history.",
          style: GoogleFonts.lora(),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person_outline),
            Icon(Icons.arrow_forward),
            Icon(Icons.lock_outline),
          ],
        ),
      ],
    ),
  );

  factory _FeatureCard.itemBased() => _FeatureCard(
    title: "Item-Based Recommendations",
    icon: Icons.auto_awesome,
    borderColor: _BookProjectShowcasePageState.coolAccent,
    content: Column(
      children: [
        Text(
          "Suggests books similar to the one you’re viewing using item-to-item collaborative filtering.",
          style: GoogleFonts.lora(),
        ),
        const SizedBox(height: 15),
        Row(
          children: const [
            Icon(Icons.book, color: _BookProjectShowcasePageState.coolAccent),
            SizedBox(width: 8),
            Text("If you liked 'Dune', try 'Foundation'!"),
          ],
        ),
      ],
    ),
  );

  factory _FeatureCard.collaborative() => _FeatureCard(
    title: "Collaborative Recommendations",
    icon: Icons.people_alt,
    borderColor: _BookProjectShowcasePageState.vibrantGreen,
    content: Column(
      children: [
        Text(
          "Recommends books based on what similar users have enjoyed.",
          style: GoogleFonts.lora(),
        ),
        const SizedBox(height: 15),
        Row(
          children: const [
            Icon(
              Icons.group,
              color: _BookProjectShowcasePageState.vibrantGreen,
            ),
            SizedBox(width: 8),
            Text("Readers like you also enjoyed..."),
          ],
        ),
      ],
    ),
  );

  factory _FeatureCard.llm() => _FeatureCard(
    title: "LLM Recommendations",
    icon: Icons.smart_toy,
    borderColor: _BookProjectShowcasePageState.deepPurple,
    content: Column(
      children: [
        Text(
          "Uses large language models to suggest books based on your interests and reading history.",
          style: GoogleFonts.lora(),
        ),
        const SizedBox(height: 15),
        Row(
          children: const [
            Icon(
              Icons.lightbulb,
              color: _BookProjectShowcasePageState.deepPurple,
            ),
            SizedBox(width: 8),
            Text("AI-powered suggestions just for you!"),
          ],
        ),
      ],
    ),
  );

  factory _FeatureCard.emotionBased() => _FeatureCard(
    title: "Emotion-Based Recommendations",
    icon: Icons.emoji_emotions,
    borderColor: _BookProjectShowcasePageState.warmAccent,
    content: Column(
      children: [
        Text(
          "Find books that match your current mood or emotional needs.",
          style: GoogleFonts.lora(),
        ),
        const SizedBox(height: 15),
        Row(
          children: const [
            Icon(Icons.mood, color: _BookProjectShowcasePageState.warmAccent),
            SizedBox(width: 8),
            Text("Feeling adventurous? Try a thriller!"),
          ],
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _BookProjectShowcasePageState.parchment,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(5, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: borderColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          content,
        ],
      ),
    );
  }
}

class _TechBubble extends StatelessWidget {
  final String text;
  const _TechBubble(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _BookProjectShowcasePageState.parchment.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.lato(
          color: _BookProjectShowcasePageState.parchment,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ScrollFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  const _ScrollFadeIn({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
  });
  @override
  __ScrollFadeInState createState() => __ScrollFadeInState();
}

class __ScrollFadeInState extends State<_ScrollFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0.05 &&
        _controller.status != AnimationStatus.completed) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: _onVisibilityChanged,
      child: FadeTransition(opacity: _opacity, child: widget.child),
    );
  }
}

// NOTE: Remember to add a 'linux_logo.png' to an 'assets' folder and
// declare it in your pubspec.yaml if you use the cross-platform card as-is.
// You can find a suitable creative commons logo online easily.

// pubspec.yaml:
// flutter:
//   assets:
//     - assets/
