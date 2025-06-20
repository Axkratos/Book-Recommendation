import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

// Enum to easily switch between the two modern styles
enum ModernStyle { glassmorphism, neumorphism }

// A modern, vibrant color palette
class ModernColor {
  static const Color background = Color(0xFF1A1A2E); // Deep indigo
  static const Color surface = Color(0xFF16213E); // Slightly lighter surface
  static const Color primary = Color(0xFF0F3460);
  static const Color accent = Color(0xFFE94560);
  static const Color lightText = Color.fromARGB(255, 0, 0, 0);
  static const Color darkText = Color.fromARGB(255, 83, 77, 77);
  static const Color darkerText = Color.fromARGB(255, 0, 0, 0);

  // For Neumorphism shadows
  static const Color lightShadow = Color(0x66FFFFFF);
  static const Color darkShadow = Color(0x66000000);

  // For Glassmorphism gradient
  static const Gradient glassGradient = LinearGradient(
    colors: [
      Color(0x33FFFFFF), // More transparent
      Color(0x1AFFFFFF), // Less transparent
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class ModernBookListItem extends StatelessWidget {
  final Map<String, dynamic> book;
  final ModernStyle style;
  final Duration animationDelay;

  const ModernBookListItem({
    super.key,
    required this.book,
    this.style = ModernStyle.glassmorphism,
    this.animationDelay = const Duration(milliseconds: 0),
  });

  @override
  Widget build(BuildContext context) {
    String? isbn10 = book['isbn10'] as String?;
    String title = book['title'] as String? ?? 'Unknown Title';
    String author = book['authors'] as String? ?? 'Unknown Author';
    String? imageUrl = book['thumbnail'] as String?;

    final TextStyle itemTitleStyle = GoogleFonts.poppins(
      color: ModernColor.lightText,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
    final TextStyle itemAuthorStyle = GoogleFonts.poppins(
      color: ModernColor.darkText,
      fontSize: 13,
      fontWeight: FontWeight.w400,
    );

    // The main widget is wrapped in Animate for a slick entry animation
    return Animate(
      delay: animationDelay,
      effects: const [
        FadeEffect(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        ),
        SlideEffect(
          begin: Offset(0, 0.3),
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _AnimatedHoverWrapper(
          child: GestureDetector(
            onTap: () {
              if (isbn10 != null && isbn10.isNotEmpty) {
                context.go('/book/$isbn10/${Uri.encodeComponent(title)}');
              }
            },
            child:
                style == ModernStyle.glassmorphism
                    ? _buildGlassmorphicContainer(
                      child: _buildContent(
                        imageUrl,
                        title,
                        author,
                        itemTitleStyle,
                        itemAuthorStyle,
                      ),
                    )
                    : _buildNeumorphicContainer(
                      child: _buildContent(
                        imageUrl,
                        title,
                        author,
                        itemTitleStyle,
                        itemAuthorStyle,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  // Helper method to build the Glassmorphism container
  Widget _buildGlassmorphicContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            gradient: ModernColor.glassGradient,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // Helper method to build the Neumorphism container
  Widget _buildNeumorphicContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: ModernColor.surface,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          // Dark shadow (bottom right)
          BoxShadow(
            color: ModernColor.darkShadow,
            offset: Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
          // Light shadow (top left)
          BoxShadow(
            color: ModernColor.lightShadow,
            offset: Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  // The actual content (Row with image and text)
  Widget _buildContent(
    String? imageUrl,
    String title,
    String author,
    TextStyle titleStyle,
    TextStyle authorStyle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 90,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child:
                imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[800]!,
                          highlightColor: Colors.grey[700]!,
                          child: Container(color: Colors.white),
                        );
                      },
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: ModernColor.primary,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: ModernColor.darkText,
                            ),
                          ),
                    )
                    : Container(
                      color: ModernColor.primary,
                      child: Icon(
                        Icons.book_outlined,
                        color: ModernColor.darkText,
                        size: 30,
                      ),
                    ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: titleStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                "by $author",
                style: authorStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// A stateful wrapper to handle hover/tap animations for instant feedback
class _AnimatedHoverWrapper extends StatefulWidget {
  final Widget child;
  const _AnimatedHoverWrapper({required this.child});

  @override
  State<_AnimatedHoverWrapper> createState() => __AnimatedHoverWrapperState();
}

class __AnimatedHoverWrapperState extends State<_AnimatedHoverWrapper> {
  bool _isHovered = false;
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isTapped ? 0.95 : (_isHovered ? 1.05 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isTapped = true),
        onTapUp: (_) => setState(() => _isTapped = false),
        onTapCancel: () => setState(() => _isTapped = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: widget.child,
        ),
      ),
    );
  }
}
