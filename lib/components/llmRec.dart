import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart'; // Using Google Fonts for a modern look

// Dummy constants for demonstration. Replace with your actual theme files if needed.
const vintageCreamllm = Color(0xFFF5F5DC);
final vintageTextStylellm =
    GoogleFonts.poppins(); // Using a modern font like Poppins

class AIPromptSection extends StatefulWidget {
  const AIPromptSection({Key? key}) : super(key: key);

  @override
  _AIPromptSectionState createState() => _AIPromptSectionState();
}

// We add SingleTickerProviderStateMixin to allow the widget to host animations.
class _AIPromptSectionState extends State<AIPromptSection>
    with SingleTickerProviderStateMixin {
  final _promptController = TextEditingController();
  bool _isSummoning = false; // State to track the button's loading status

  // Animation controller for the entrance animation
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Fade in animation
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    // Slide in from the bottom animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start the animation when the widget is first built
    _animationController.forward();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // --- Core Action Logic ---
  Future<void> _summonBook() async {
    // Prevent multiple submissions while loading
    if (_isSummoning) return;

    final prompt = _promptController.text.trim();
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    if (prompt.isNotEmpty) {
      setState(() {
        _isSummoning = true; // Start the loading animation
      });

      // Simulate a network delay to showcase the loading animation
      await Future.delayed(const Duration(milliseconds: 1500));

      // Check if the widget is still in the tree before navigating
      if (mounted) {
        context.push('/dashboard/home/book/$prompt');
      }

      // It's good practice to check `mounted` again before setting state
      // if your async gap is long, though after navigation it might not be needed.
      if (mounted) {
        setState(() {
          _isSummoning = false; // Reset the button
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Please enter a magical prompt!',
            style: vintageTextStylellm.copyWith(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // The entrance animation wrapper
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16.0),
          decoration: _buildContainerDecoration(),
          // Use LayoutBuilder to create a responsive UI
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use a breakpoint to switch between mobile and desktop layouts
              const double breakpoint = 600.0;
              if (constraints.maxWidth < breakpoint) {
                return _buildMobileLayout(context);
              } else {
                return _buildDesktopLayout(context);
              }
            },
          ),
        ),
      ),
    );
  }

  // --- Layout Builders ---

  /// Vertical layout optimized for mobile screens.
  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0), // Reduced padding for mobile
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(fontSize: 17), // Smaller header
          const SizedBox(height: 10),
          _buildPromptTextField(fontSize: 14),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: _buildSummonButton(isMobile: true),
          ),
        ],
      ),
    );
  }

  /// Horizontal layout optimized for tablet and desktop screens.
  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildHeader()),
          const SizedBox(width: 24),
          Expanded(flex: 3, child: _buildPromptTextField()),
          const SizedBox(width: 20),
          _buildSummonButton(),
        ],
      ),
    );
  }

  // --- Reusable Widget Parts ---

  Widget _buildHeader({
    TextAlign textAlign = TextAlign.start,
    double fontSize = 22,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.auto_awesome_outlined, color: Colors.white, size: 24),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            "Conjure Your Next Read",
            textAlign: textAlign,
            style: GoogleFonts.orbitron(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                const Shadow(color: Colors.cyan, blurRadius: 10),
                const Shadow(color: Colors.pinkAccent, blurRadius: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptTextField({double fontSize = 16}) {
    return TextField(
      controller: _promptController,
      style: vintageTextStylellm.copyWith(
        color: Colors.white,
        fontSize: fontSize,
      ),
      decoration: InputDecoration(
        hintText: "A sci-fi epic on a desert planet...",
        hintStyle: vintageTextStylellm.copyWith(
          color: Colors.white54,
          fontSize: fontSize - 2,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        prefixIcon: const Icon(
          Icons.edit_note,
          color: Colors.white70,
          size: 20,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
      ),
    );
  }

  Widget _buildSummonButton({bool isMobile = false}) {
    return ElevatedButton.icon(
      onPressed: _summonBook,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: isMobile ? 10 : 16,
        ),
        backgroundColor: const Color(0xFFF02E9A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        foregroundColor: Colors.white,
        shadowColor: Colors.pinkAccent,
        elevation: 8,
        textStyle: vintageTextStylellm.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: isMobile ? 14 : 16,
        ),
      ),
      icon:
          _isSummoning
              ? Container()
              : Icon(Icons.auto_awesome, size: isMobile ? 18 : 20),
      label:
          _isSummoning
              ? SizedBox(
                height: isMobile ? 16 : 20,
                width: isMobile ? 16 : 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              )
              : Text("Summon"),
    );
  }

  // A sleek, modern decoration for the container
  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20.0),
      // A subtle border that uses a gradient
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      boxShadow: [
        // A cyan glow
        BoxShadow(
          color: Colors.cyan.withOpacity(0.5),
          blurRadius: 25,
          spreadRadius: -10,
          offset: const Offset(-10, -10),
        ),
        // A magenta glow
        BoxShadow(
          color: Colors.pink.withOpacity(0.5),
          blurRadius: 25,
          spreadRadius: -10,
          offset: const Offset(10, 10),
        ),
      ],
    );
  }
}
