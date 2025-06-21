import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- MAIN WIDGET: THE "RENAISSANCE ATHENAEUM" LANDING PAGE ---
class RenaissanceAthenaeumPage extends StatefulWidget {
  const RenaissanceAthenaeumPage({super.key});

  @override
  State<RenaissanceAthenaeumPage> createState() =>
      _RenaissanceAthenaeumPageState();
}

class _RenaissanceAthenaeumPageState extends State<RenaissanceAthenaeumPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _particleController;
  Offset _mousePosition = Offset.zero;
  double _scrollOffset = 0;

  final List<GoldenMote> _motes = [];

  // Vibrant, yet sophisticated color palette
  static const Color parchment = Color(0xfffdf6e3);
  static const Color sepiaInk = Color(0xff5d4037);
  static const Color goldAccent = Color(0xffd4af37); // Brighter Gold
  static const Color tealAccent = Color(0xff008080);
  static const Color terracottaAccent = Color(0xffE2725B);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..addListener(_updateMotes);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMotes(MediaQuery.of(context).size);
      _particleController.repeat();
    });
  }

  void _initializeMotes(Size size) {
    final random = Random();
    for (int i = 0; i < 40; i++) {
      _motes.add(GoldenMote(
        position: Offset(
            random.nextDouble() * size.width, random.nextDouble() * size.height),
        velocity: Offset(
            (random.nextDouble() - 0.5) * 0.4, (random.nextDouble() - 0.5) * 0.4),
        radius: random.nextDouble() * 1.5 + 1.0,
      ));
    }
  }

  void _updateMotes() {
    final size = MediaQuery.of(context).size;
    if (size.isEmpty) return;
    for (var mote in _motes) {
      mote.position += mote.velocity;
      if (mote.position.dx < 0) mote.position = Offset(size.width, mote.position.dy);
      if (mote.position.dx > size.width) mote.position = Offset(0, mote.position.dy);
      if (mote.position.dy < 0) mote.position = Offset(mote.position.dx, size.height);
      if (mote.position.dy > size.height) mote.position = Offset(mote.position.dx, 0);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  double _getSectionProgress(double sectionTop, double sectionHeight) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Tighter scroll trigger for a more compact feel
    double progress = (_scrollOffset - sectionTop + screenHeight * 0.9) /
        (sectionHeight + screenHeight * 0.1);
    return progress.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    // Adjusted section heights for compactness, now 9 sections total
    final sectionHeights = List.generate(9, (_) => isMobile ? 800.0 : 900.0);
    // Make the tech stack section taller to accommodate more info
    sectionHeights[5] = isMobile ? 1200.0 : 1000.0; 
    
    final sectionTops = [0.0];
    for (int i = 0; i < sectionHeights.length - 1; i++) {
      sectionTops.add(sectionTops.last + sectionHeights[i]);
    }

    return Scaffold(
      backgroundColor: parchment,
      body: MouseRegion(
        onHover: (event) => setState(() => _mousePosition = event.position),
        child: Stack(
          children: [
            _GoldenMoteBackground(motes: _motes),
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _SectionContainer(height: sectionHeights[0], child: _buildHeroSection(isMobile)),
                  _SectionContainer(height: sectionHeights[1], child: _buildManifestoSection(isMobile, _getSectionProgress(sectionTops[1], sectionHeights[1]))),
                  _SectionContainer(height: sectionHeights[2], child: _buildAnatomyOfAStorySection(isMobile, _getSectionProgress(sectionTops[2], sectionHeights[2]))),
                  _SectionContainer(height: sectionHeights[3], child: _buildDiscoverySection(isMobile)),
                  _SectionContainer(height: sectionHeights[4], child: _buildCommunitySection(isMobile, _getSectionProgress(sectionTops[4], sectionHeights[4]))),
                  _SectionContainer(height: sectionHeights[5], child: _buildTechStackSection(isMobile, _getSectionProgress(sectionTops[5], sectionHeights[5]))),
                  _SectionContainer(height: sectionHeights[6], child: _buildBookshelfSection(isMobile, _getSectionProgress(sectionTops[6], sectionHeights[6]))),
                  _SectionContainer(height: sectionHeights[7], child: _buildPlatformSection(isMobile, _getSectionProgress(sectionTops[7], sectionHeights[7]))),
                  _SectionContainer(height: sectionHeights[8], child: _buildCtaSection(isMobile)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SECTION BUILDERS ---
  Widget _buildHeroSection(bool isMobile) => Center(
        child: Text(
          "The\nAlgorithm\nof Stories.",
          textAlign: TextAlign.center,
          style: GoogleFonts.ebGaramond(
            fontSize: isMobile ? 60 : 100,
            fontWeight: FontWeight.w600,
            color: sepiaInk,
            height: 1.1,
          ),
        ),
      );

  Widget _buildManifestoSection(bool isMobile, double progress) => _SectionContent(
        isMobile: isMobile,
        progress: progress,
        title: "From Codex to Code",
        accentColor: terracottaAccent,
        body:
            "We see knowledge not as static entries in a database, but as a living tapestry. BookRec merges the wisdom of the ages with intelligent algorithms to illuminate the hidden connections between stories, authors, and ideas, creating a literary journey as unique as you are.",
      );

  Widget _buildAnatomyOfAStorySection(bool isMobile, double progress) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SectionHeader(title: "The Anatomy of a Story", progress: progress, accentColor: tealAccent),
          const SizedBox(height: 20),
          Expanded(child: _VitruvianVisualizer(progress: progress)),
        ],
      );

  Widget _buildDiscoverySection(bool isMobile) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(title: "Explore the Great Library", progress: 1.0, isStatic: true, accentColor: goldAccent),
          const SizedBox(height: 60),
          _Marquee(text: "PLATO • ARISTOTLE • MARY SHELLEY • SHAKESPEARE • DOSTOEVSKY • TOLKIEN • ASIMOV • ", color: sepiaInk.withOpacity(0.7)),
          const SizedBox(height: 20),
          const _Marquee(text: "COSMOLOGY • PHILOSOPHY • ALCHEMY • MYTHOLOGY • FRANKENSTEIN • AI • ETHICS •", reversed: true, duration: Duration(seconds: 45), color: terracottaAccent),
          const SizedBox(height: 20),
          _Marquee(text: "KNOWLEDGE • CREATION • GODS • MONSTERS • HUMANITY • THE FUTURE • THE PAST • ", duration: Duration(seconds: 60), color: sepiaInk.withOpacity(0.7)),
          const SizedBox(height: 20),
          const _Marquee(text: "FLUTTER • PYTHON • PANDAS • SCIKIT-LEARN • FLASK • REACT • AWS • JUPYTER •", reversed: true, duration: Duration(seconds: 50), color: tealAccent),
        ],
      );
  
  Widget _buildCommunitySection(bool isMobile, double progress) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SectionHeader(title: "A Constellation of Minds", progress: progress, accentColor: terracottaAccent),
          const SizedBox(height: 20),
          Expanded(child: _ConstellationVisualizer(progress: progress)),
        ],
      );

  Widget _buildTechStackSection(bool isMobile, double progress) {
    Widget textColumn = Expanded(
      flex: isMobile ? 0 : 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: "The Digital Athenaeum's Engine", progress: progress, accentColor: tealAccent),
          const SizedBox(height: 25),
          _TechInfoPanel(
              title: "Data Science & Machine Learning",
              body:
                  "Our recommendation core is powered by Python, utilizing libraries like Pandas and Scikit-learn. We employ a hybrid model of collaborative and content-based filtering to analyze metadata, user ratings, and textual content, ensuring nuanced and accurate suggestions.",
              progress: progress),
          const SizedBox(height: 25),
          _TechInfoPanel(
              title: "Full-Stack Architecture",
              body:
                  "A robust Flask & Flutter framework delivers a seamless experience. The backend provides RESTful APIs for data, while the frontend is built with Flutter for a highly performant, natively-compiled application on web, mobile, and desktop from a single codebase.",
              progress: progress),
        ],
      ),
    );
    
    Widget visualColumn = Expanded(
      flex: isMobile ? 0 : 2,
      child: _TechStackVisualizer(progress: progress),
    );

    if(isMobile) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [textColumn, const SizedBox(height: 40), SizedBox(height: 300, child: visualColumn)],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        textColumn,
        const SizedBox(width: 50),
        visualColumn,
      ],
    );
  }

  Widget _buildBookshelfSection(bool isMobile, double progress) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SectionHeader(title: "Your Personal Grimoire", progress: progress, accentColor: goldAccent),
          const SizedBox(height: 20),
          Expanded(child: _GenerativeBookVisualizer(progress: progress)),
        ],
      );
  
  Widget _buildPlatformSection(bool isMobile, double progress) => _SectionContent(
        isMobile: isMobile,
        progress: progress,
        title: "The Inventor's Workshop",
        accentColor: terracottaAccent,
        body:
            "From desktop study to mobile folio, your library is always at hand. Our platform is meticulously crafted to provide a seamless, elegant experience across all your devices, as if designed by a master artisan.",
        customVisual: _ArchitecturalBlueprints(progress: progress));
  
  Widget _buildCtaSection(bool isMobile) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Begin Your Opus.",
              textAlign: TextAlign.center,
              style: GoogleFonts.ebGaramond(
                fontSize: isMobile ? 48 : 72,
                fontWeight: FontWeight.w600,
                color: sepiaInk,
              ),
            ),
            const SizedBox(height: 40),
            _CalligraphyButton(text: 'Become a Scribe', onTap: (){}),
            const SizedBox(height: 100),
            Text(
              "BookRec © ${DateTime.now().year} — Crafted with Flutter & Python",
              style: GoogleFonts.lato(color: Colors.brown[300], fontSize: 14),
            ),
          ],
        ),
      );
}

// --- DATA & HELPER WIDGETS ---

class GoldenMote {
  Offset position;
  Offset velocity;
  double radius;
  GoldenMote({required this.position, required this.velocity, required this.radius});
}

class _SectionContainer extends StatelessWidget {
  final Widget child;
  final double height;
  const _SectionContainer({required this.child, required this.height});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.symmetric(
          horizontal: width > 850 ? 100 : 30, vertical: 50),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final double progress;
  final bool isStatic;
  final Color accentColor;

  const _SectionHeader({
    required this.title, 
    required this.progress, 
    this.isStatic = false, 
    required this.accentColor
  });

  @override
  Widget build(BuildContext context) {
    final tProgress = Curves.easeOut.transform(progress);
    return Opacity(
      opacity: isStatic ? 1.0 : tProgress,
      child: Transform.translate(
        offset: isStatic ? Offset.zero : Offset(0, 30 * (1 - tProgress)),
        child: Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
            color: accentColor,
          ),
        ),
      ),
    );
  }
}

class _SectionContent extends StatelessWidget {
    final bool isMobile;
    final double progress;
    final String title;
    final String body;
    final Color accentColor;
    final Widget? customVisual;

  const _SectionContent({
    required this.isMobile,
    required this.progress,
    required this.title,
    required this.body,
    required this.accentColor,
    this.customVisual
  });

  @override
  Widget build(BuildContext context) {
    Widget textContent = SizedBox(
        width: isMobile ? double.infinity : 500,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
                _SectionHeader(title: title, progress: progress, accentColor: accentColor),
                const SizedBox(height: 25),
                Text(
                  body,
                  textAlign: isMobile ? TextAlign.center : TextAlign.left,
                  style: GoogleFonts.lato(
                    fontSize: isMobile ? 18 : 19,
                    height: 1.7,
                    color: _RenaissanceAthenaeumPageState.sepiaInk,
                  ),
                ),
            ],
        ),
    );
    
     if (customVisual == null) return Center(child: textContent);

    final arrangement = isMobile
        ? Column(children: [textContent, const SizedBox(height: 40), Expanded(child: customVisual!)])
        : Row(children: [Expanded(flex: 3, child: textContent), const SizedBox(width: 60), Expanded(flex: 2, child: customVisual!)]);

    return Opacity(
      opacity: Curves.easeIn.transform(progress),
      child: arrangement,
    );
  }
}

class _TechInfoPanel extends StatelessWidget {
  final String title;
  final String body;
  final double progress;
  const _TechInfoPanel({required this.title, required this.body, required this.progress});
  
  @override
  Widget build(BuildContext context) {
    final tProgress = Curves.easeOutCubic.transform(progress);
    return Opacity(
      opacity: tProgress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(title, style: GoogleFonts.ebGaramond(
              fontSize: 24, 
              color: _RenaissanceAthenaeumPageState.sepiaInk,
              fontWeight: FontWeight.bold)),
           const SizedBox(height: 8),
           Text(body, style: GoogleFonts.lato(
              fontSize: 16,
              height: 1.6,
              color: _RenaissanceAthenaeumPageState.sepiaInk.withOpacity(0.8),
           ))
        ],
      ),
    );
  }
}


class _CalligraphyButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _CalligraphyButton({required this.text, required this.onTap});

  @override
  __CalligraphyButtonState createState() => __CalligraphyButtonState();
}

class __CalligraphyButtonState extends State<_CalligraphyButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.text,
              style: GoogleFonts.ebGaramond(
                  color: _RenaissanceAthenaeumPageState.sepiaInk,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              width: _isHovered ? 120 : 60,
              color: _RenaissanceAthenaeumPageState.goldAccent,
            )
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTERS AND GENERATIVE VISUALS ---

class _GoldenMoteBackground extends StatelessWidget {
  final List<GoldenMote> motes;
  const _GoldenMoteBackground({required this.motes});
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _GoldenMotePainter(motes),
    );
  }
}
class _GoldenMotePainter extends CustomPainter {
  final List<GoldenMote> motes;
  _GoldenMotePainter(this.motes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _RenaissanceAthenaeumPageState.goldAccent.withOpacity(0.5);
    for(var mote in motes){
       canvas.drawCircle(mote.position, mote.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class _VitruvianVisualizer extends StatelessWidget {
  final double progress;
  const _VitruvianVisualizer({required this.progress});
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: _VitruvianPainter(Curves.easeInOut.transform(progress)),
    );
  }
}
class _VitruvianPainter extends CustomPainter {
  final double progress;
  _VitruvianPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if(progress == 0) return;
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 3;

    final paint = Paint()
      ..color = _RenaissanceAthenaeumPageState.sepiaInk.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Draw Circle
    canvas.drawCircle(center, radius * progress, paint);
    
    // Draw Square
    final halfSide = radius * (1 / sqrt(2));
    final rect = Rect.fromCenter(center: center, width: halfSide * 2 * progress, height: halfSide * 2 * progress);
    canvas.drawRect(rect, paint);
    
    // Draw central abstract "book" or "frankenstein core"
    final corePaint = Paint()
      ..color = _RenaissanceAthenaeumPageState.tealAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final innerRadius = radius * 0.3 * progress;
    final path = Path();
    for (int i=0; i < 5; i++) {
        final angle1 = i * (pi*2/5) + progress*pi;
        final angle2 = (i+2) * (pi*2/5) + progress*pi;
        
        if (i==0) {
            path.moveTo(
              center.dx + cos(angle1) * innerRadius,
              center.dy + sin(angle1) * innerRadius
            );
        }
        path.lineTo(
            center.dx + cos(angle2) * innerRadius,
            center.dy + sin(angle2) * innerRadius
        );
    }
    path.close();
    canvas.drawPath(
        Path.from(path.computeMetrics().first.extractPath(0, path.computeMetrics().first.length * progress)), 
        corePaint);
    
    // Draw knowledge lines
    final numLines = (10 * progress).floor();
    for (int i=0; i<numLines; i++){
        final angle = (i/10) * pi * 2;
        final start = center + Offset(cos(angle), sin(angle)) * (innerRadius + 5);
        final end = center + Offset(cos(angle), sin(angle)) * radius;
        canvas.drawLine(start, end, paint..strokeWidth=0.5);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class _ConstellationVisualizer extends StatelessWidget {
    final double progress;
    const _ConstellationVisualizer({required this.progress});
    
    @override
    Widget build(BuildContext context) {
       return CustomPaint(
          size: const Size(double.infinity, double.infinity),
          painter: _ConstellationPainter(Curves.easeOut.transform(progress)),
       );
    }
}
class _ConstellationPainter extends CustomPainter {
    final double progress;
    final List<Offset> points = [];

    _ConstellationPainter(this.progress){
        final random = Random(42);
        for(int i = 0; i < 25; i++){
          points.add(Offset(random.nextDouble(), random.nextDouble()));
        }
    }
    
    @override
    void paint(Canvas canvas, Size size) {
       if (progress == 0) return;
       
       final starPaint = Paint()..color = _RenaissanceAthenaeumPageState.goldAccent;
       final linePaint = Paint()
          ..color = _RenaissanceAthenaeumPageState.terracottaAccent.withOpacity(0.5)
          ..strokeWidth = 1.0;
        
       final scaledPoints = points.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();

       // Draw connections first
       final linesToDraw = (scaledPoints.length * 1.5 * progress).floor();
       int lineCount = 0;

       for(int i=0; i < scaledPoints.length; i++) {
           for(int j=i+1; j < scaledPoints.length; j++){
               if (lineCount >= linesToDraw) break;
               final distance = (scaledPoints[i] - scaledPoints[j]).distance;
               if(distance < size.width * 0.25){
                 canvas.drawLine(scaledPoints[i], scaledPoints[j], linePaint);
                 lineCount++;
               }
           }
       }

       // Draw stars
       final starsToDraw = (scaledPoints.length * progress).floor();
       for(int i=0; i<starsToDraw; i++){
         canvas.drawCircle(scaledPoints[i], 3, starPaint);
       }
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class _GenerativeBookVisualizer extends StatelessWidget {
    final double progress;
    const _GenerativeBookVisualizer({required this.progress});

    @override
    Widget build(BuildContext context) {
      return CustomPaint(
        size: const Size(double.infinity, double.infinity),
        painter: _BookPainter(Curves.easeOutCubic.transform(progress))
      );
    }
}
class _BookPainter extends CustomPainter {
    final double progress;
    _BookPainter(this.progress);

    @override
    void paint(Canvas canvas, Size size) {
        if(progress == 0) return;

        final center = size.center(Offset.zero);
        final bookHeight = size.height * 0.65;
        final bookWidth = bookHeight * 0.8;
        
        final bookPaint = Paint()
          ..color = _RenaissanceAthenaeumPageState.sepiaInk.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        final path = Path();
        path.moveTo(center.dx, center.dy - bookHeight / 2); // Top of spine
        path.quadraticBezierTo(
          center.dx - bookWidth/2 - 20, center.dy,
          center.dx, center.dy + bookHeight / 2 // Bottom of spine
        );
         path.quadraticBezierTo(
          center.dx + bookWidth/2 + 20, center.dy,
          center.dx, center.dy - bookHeight / 2 // Back to top
        );
        path.close();
        
        final animatedPath = Path.from(path.computeMetrics().first.extractPath(0, path.computeMetrics().first.length * progress));
        canvas.drawPath(animatedPath, bookPaint);
        
        // Draw content inside
        if (progress > 0.5) {
          final contentProgress = (progress-0.5)*2;
          final contentPaint = Paint()..color = _RenaissanceAthenaeumPageState.terracottaAccent.withOpacity(0.7)..strokeWidth=1.0;
          for (int i=0; i<10; i++){
            final y = lerpDouble(center.dy - bookHeight/3, center.dy + bookHeight/3, i/9)!;
            final lineLength = bookWidth * 0.3 * contentProgress;
            canvas.drawLine(Offset(center.dx-bookWidth*0.35, y), Offset(center.dx-bookWidth*0.35 + lineLength, y), contentPaint);
          }
           final diagramPaint = Paint()..color=_RenaissanceAthenaeumPageState.tealAccent..strokeWidth=1.5..style=PaintingStyle.stroke;
           canvas.drawCircle(Offset(center.dx + bookWidth * 0.2, center.dy), bookWidth * 0.1 * contentProgress, diagramPaint);
        }
    }
    
    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class _TechStackVisualizer extends StatelessWidget {
    final double progress;
    const _TechStackVisualizer({required this.progress});

    @override
    Widget build(BuildContext context) {
        return CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: _TechStackPainter(Curves.easeInOut.transform(progress)),
        );
    }
}
class _TechStackPainter extends CustomPainter {
    final double progress;
    _TechStackPainter(this.progress);

    @override
    void paint(Canvas canvas, Size size) {
        if(progress == 0) return;
        final center = size.center(Offset.zero);
        
        final layers = [
            {'name': 'Python / Pandas / Scikit-Learn', 'color': _RenaissanceAthenaeumPageState.tealAccent, 'radius': 0.8},
            {'name': 'Flutter / Dart', 'color': _RenaissanceAthenaeumPageState.terracottaAccent, 'radius': 0.6},
            {'name': 'Flask / SQL / AWS', 'color': _RenaissanceAthenaeumPageState.goldAccent, 'radius': 0.35},
        ];

        for(var layer in layers){
          _drawLayer(canvas, size, center, layer['name'] as String, layer['color'] as Color, layer['radius'] as double);
        }
    }
    
    void _drawLayer(Canvas canvas, Size size, Offset center, String name, Color color, double radiusFactor){
      final radius = (min(size.width, size.height) / 2.2) * radiusFactor;
      final layerProgress = (progress - (1-radiusFactor) * 0.5).clamp(0.0, 1.0) / (radiusFactor + 0.1);
      if (layerProgress == 0) return;
      
      final paint = Paint()..color = color.withOpacity(0.8)..strokeWidth=1.5..style=PaintingStyle.stroke;

      final path = Path();
      final angleOffset = (1 - radiusFactor) * pi;
      path.addArc(Rect.fromCircle(center: center, radius: radius), angleOffset, (pi * 1.5) * layerProgress);
      canvas.drawPath(path, paint);

      final textAngle = (pi/4) + angleOffset;
      final textStartPoint = center + Offset(cos(textAngle), sin(textAngle)) * radius;
      final textEndPoint = center + Offset(cos(textAngle), sin(textAngle)) * (radius + 20);

      if (layerProgress > 0.5){
        final textLineProgress = (layerProgress - 0.5) * 2;
        canvas.drawLine(textStartPoint, Offset.lerp(textStartPoint, textEndPoint, textLineProgress)!, paint..strokeWidth = 1.0);
        
        if (textLineProgress > 0.8) {
           final textPainter = TextPainter(
              text: TextSpan(text: name, style: GoogleFonts.lato(fontSize: 14, color: color, fontWeight: FontWeight.bold)),
              textDirection: TextDirection.ltr
            )..layout();
           textPainter.paint(canvas, textEndPoint + const Offset(5, -8));
        }
      }
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class _ArchitecturalBlueprints extends StatelessWidget {
  final double progress;
  const _ArchitecturalBlueprints({required this.progress});

  @override
  Widget build(BuildContext context) {
    final tProgress = Curves.easeInOutCubic.transform(progress);
    
    final desktop = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..translate(150 * (1-tProgress), 0.0)
      ..rotateY(-0.7 * (1 - tProgress));

    final mobile = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..translate(-150 * (1-tProgress), 50.0)
      ..rotateY(0.7 * (1 - tProgress));
    
    return Stack(
      alignment: Alignment.center,
      children: [
          Transform(
            transform: desktop, alignment: Alignment.center,
            child: const _Blueprint(width: 450, height: 280),
          ),
          Transform(
            transform: mobile, alignment: Alignment.center,
            child: const _Blueprint(width: 140, height: 280),
          )
      ],
    );
  }
}
class _Blueprint extends StatelessWidget {
  final double width;
  final double height;
  const _Blueprint({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _RenaissanceAthenaeumPageState.tealAccent.withOpacity(0.05), // Blueprint blue
        border: Border.all(color: _RenaissanceAthenaeumPageState.tealAccent.withOpacity(0.7), width: 1.5),
        borderRadius: BorderRadius.circular(5)
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
        child: const SizedBox.expand(),
      )
    );
  }
}


class _Marquee extends StatefulWidget {
    final String text;
    final Duration duration;
    final bool reversed;
    final Color color;
    
    const _Marquee({required this.text, this.duration = const Duration(seconds: 30), this.reversed=false, required this.color});

    @override
    __MarqueeState createState() => __MarqueeState();
}
class __MarqueeState extends State<_Marquee> with SingleTickerProviderStateMixin {
    late AnimationController _controller;
    
    @override
    void initState() {
      super.initState();
       _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
    }
    
    @override
    void dispose() { _controller.dispose(); super.dispose();}
    
    @override
    Widget build(BuildContext context) {
       return AnimatedBuilder(
           animation: _controller,
           builder: (context, child){
               return CustomPaint(
                 size: const Size(double.infinity, 30),
                 painter: _MarqueePainter(
                   text: widget.text,
                   color: widget.color,
                   progress: widget.reversed ? 1.0 - _controller.value : _controller.value
                 )
               );
           }
       );
    }
}
class _MarqueePainter extends CustomPainter {
    final String text;
    final double progress;
    final Color color;
    _MarqueePainter({required this.text, required this.progress, required this.color});
    @override
    void paint(Canvas canvas, Size size) {
        final textStyle = TextStyle(
          fontFamily: GoogleFonts.lato().fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: color
        );
        final textPainter = TextPainter(text: TextSpan(text: text, style: textStyle), textDirection: TextDirection.ltr)..layout();
        final textWidth = textPainter.width;
        
        double dx = lerpDouble(0, -textWidth, progress)!;

        canvas.save();
        canvas.clipRect(Rect.fromLTWH(0,0, size.width, size.height));
        while(dx < size.width){
            textPainter.paint(canvas, Offset(dx, 0));
            dx += textWidth;
        }
        canvas.restore();
    }
    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}