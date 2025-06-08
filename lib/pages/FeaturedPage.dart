import 'package:bookrec/components/footer.dart';
import 'package:bookrec/services/booksapi.dart'; // Assuming this exists
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

// Placeholder for your SimpleElegantVintageFooter if it's not in the provided code
// class SimpleElegantVintageFooter extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 100,
//       color: Colors.brown[100],
//       child: Center(child: Text("Footer Placeholder")),
//     );
//   }
// }

class FeaturedPage extends StatefulWidget {
  const FeaturedPage({super.key});

  @override
  State<FeaturedPage> createState() => _FeaturedpageState();
}

class _FeaturedpageState extends State<FeaturedPage> {
  // Helper for responsive font sizes
  double _getResponsiveFontSize(
    double baseSize, {
    required bool isMobile,
    required bool isTablet,
    double mobileFactor = 0.7,
    double tabletFactor = 0.85,
  }) {
    if (isMobile) return baseSize * mobileFactor;
    if (isTablet) return baseSize * tabletFactor;
    return baseSize;
  }

  Widget _buildHeroSection(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    bool isMobile,
    bool isTablet,
  ) {
    double heroHeight =
        screenHeight * (isMobile ? 0.45 : (isTablet ? 0.35 : 0.3));
    double imageWidth =
        screenWidth * (isMobile ? 0.4 : (isTablet ? 0.28 : 0.3));
    double imageHeight = heroHeight * (isMobile ? 0.5 : 0.9);
    double horizontalPadding = screenWidth * (isMobile ? 0.05 : 0.09);

    List<Widget> textChildren = [
      Text(
        'Happy Readings',
        textAlign: isMobile ? TextAlign.center : TextAlign.start,
        style: GoogleFonts.playfair(
          fontSize: _getResponsiveFontSize(
            60,
            isMobile: isMobile,
            isTablet: isTablet,
            mobileFactor: 0.45,
            tabletFactor: 0.7,
          ),
          height: 1.1,
          fontWeight: FontWeight.w100,
          color: Colors.black,
          letterSpacing: 1.5,
        ),
      ),
      Text(
        'Satisfied',
        textAlign: isMobile ? TextAlign.center : TextAlign.start,
        style: GoogleFonts.fraunces(
          height: 1.1,
          fontSize: _getResponsiveFontSize(
            60,
            isMobile: isMobile,
            isTablet: isTablet,
            mobileFactor: 0.45,
            tabletFactor: 0.7,
          ),
          fontWeight: FontWeight.w100,
          color: Colors.black,
          letterSpacing: 1.5,
        ),
      ),
      Text(
        'Soul',
        textAlign: isMobile ? TextAlign.center : TextAlign.start,
        style: GoogleFonts.playfair(
          fontSize: _getResponsiveFontSize(
            60,
            isMobile: isMobile,
            isTablet: isTablet,
            mobileFactor: 0.45,
            tabletFactor: 0.7,
          ),
          fontWeight: FontWeight.w100,
          color: Colors.black,
          letterSpacing: 1.5,
        ),
      ),
    ];

    Widget textColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: textChildren,
    );

    Widget image = Image.asset(
      'lib/images/final chill.png', // Ensure this path is correct
      alignment: Alignment(0, 0.7),
      fit: BoxFit.contain,
      width: imageWidth,
      height: imageHeight,
    );

    return Container(
      height: heroHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF5E8C7),
            Color.fromARGB(255, 240, 189, 170),
            Colors.amber[300]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: screenHeight * 0.01,
      ),
      child:
          isMobile
              ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [textColumn, image],
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: textColumn),
                  SizedBox(width: isTablet ? 20 : 40),
                  image,
                ],
              ),
    );
  }

  Widget _buildWhatAreWeSection(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    bool isMobile,
    bool isTablet,
    BoxConstraints constraints,
  ) {
    double itemWidth;
    double horizontalPaddingFactor = isMobile ? 0.05 : 0.09;
    double availableWidth =
        constraints.maxWidth * (1 - 2 * horizontalPaddingFactor);
    double spacing = 20.0;

    if (isMobile) {
      itemWidth =
          availableWidth * 0.9; // One item, taking most of the padded width
    } else if (isTablet) {
      itemWidth = (availableWidth - spacing) / 2; // Two items per row
    } else {
      // Web
      itemWidth = (availableWidth - (spacing * 3)) / 4; // Four items per row
    }
    // Ensure itemWidth is not negative or too small
    itemWidth = itemWidth.clamp(100.0, 400.0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Column(
        children: [
          Text(
            'What are we?',
            textAlign: TextAlign.center,
            style: GoogleFonts.literata(
              fontSize: _getResponsiveFontSize(
                42,
                isMobile: isMobile,
                isTablet: isTablet,
                mobileFactor: 0.7,
                tabletFactor: 0.85,
              ),
              color: Colors.brown[900],
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * horizontalPaddingFactor,
            ),
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: [
                FeaturesWidget(
                  // Renamed to avoid conflict
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  itemWidth: itemWidth,
                  title: 'Personalized Recommendations',
                  icon: FontAwesomeIcons.scroll,
                  isMobile: isMobile,
                  isTablet: isTablet,
                ),
                FeaturesWidget(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  itemWidth: itemWidth,
                  title: 'Daily Updates',
                  icon: FontAwesomeIcons.glasses,
                  isMobile: isMobile,
                  isTablet: isTablet,
                ),
                FeaturesWidget(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  itemWidth: itemWidth,
                  title: 'Community Reviews',
                  icon: FontAwesomeIcons.comment,
                  isMobile: isMobile,
                  isTablet: isTablet,
                ),
                FeaturesWidget(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  itemWidth: itemWidth,
                  title: 'Books Archive',
                  icon: FontAwesomeIcons.atlas,
                  isMobile: isMobile,
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartJourneySection(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    bool isMobile,
    bool isTablet,
    BoxConstraints constraints,
  ) {
    double itemWidth;
    double horizontalPaddingValue = screenWidth * (isMobile ? 0.05 : 0.09);
    // Effective max width for the content row/column within the padded section
    double effectiveContentWidth =
        constraints.maxWidth - (2 * horizontalPaddingValue);
    double spacing = 20.0;

    if (isMobile) {
      itemWidth =
          effectiveContentWidth *
          0.95; // One item almost full width of the padded area
    } else {
      // Tablet & Web
      itemWidth = (effectiveContentWidth - spacing) / 2;
    }
    // Ensure itemWidth is not negative or too small
    itemWidth = itemWidth.clamp(150.0, 600.0);

    List<Widget> openFeatureItems = [
      OpenFeaturesWidget(
        // Renamed to avoid conflict
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        itemWidth: itemWidth,
        title: 'AI Powered',
        text:
            'We utilize LLM and our own refined model to provide you with the best book recommendations. We are constantly improving our model to ensure you get the best recommendations.',
        url:
            'https://lottie.host/c5b24313-5391-4750-859e-c6dc09af8b9c/hib4Wlm1a3.json',
        isMobile: isMobile,
        isTablet: isTablet,
      ),
      SizedBox(height: isMobile ? 30 : 0, width: isMobile ? 0 : spacing),
      OpenFeaturesWidget(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        itemWidth: itemWidth,
        title: 'On the Go',
        text:
            'Our Services are provided on each of your device, android, iphone, desktop. Enjoy the readings. We are always with you and constantly improving our services. Feel free to contribute.',
        url:
            'https://lottie.host/d799f257-a4cc-4f83-8fed-0929395887bc/M0m5FxGU2Y.json',
        isMobile: isMobile,
        isTablet: isTablet,
      ),
    ];

    return Container(
      color: Color.fromARGB(255, 236, 222, 247),
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.05,
        horizontal: horizontalPaddingValue,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Start your journey with us',
            textAlign: TextAlign.center,
            style: GoogleFonts.literata(
              fontSize: _getResponsiveFontSize(
                42,
                isMobile: isMobile,
                isTablet: isTablet,
                mobileFactor: 0.65,
                tabletFactor: 0.8,
              ),
              color: Colors.brown[900],
            ),
          ),
          SizedBox(height: isMobile ? 30 : 50),
          isMobile
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: openFeatureItems,
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: openFeatureItems,
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF6F2EA),
      body: SelectionArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;
            bool isTablet =
                constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
            // bool isWeb = constraints.maxWidth >= 1200; // Not explicitly used for distinct web style, tablet often covers it

            return ListView(
              children: [
                _buildHeroSection(
                  context,
                  screenWidth,
                  screenHeight,
                  isMobile,
                  isTablet,
                ),
                _buildWhatAreWeSection(
                  context,
                  screenWidth,
                  screenHeight,
                  isMobile,
                  isTablet,
                  constraints,
                ),
                _buildStartJourneySection(
                  context,
                  screenWidth,
                  screenHeight,
                  isMobile,
                  isTablet,
                  constraints,
                ),
                Container(
                  height:
                      screenHeight * (isMobile ? 0.3 : (isTablet ? 0.5 : 0.7)),
                  child: Image.network(
                    'https://i.postimg.cc/0yzr0NLy/20250522-2141-Blooming-Cityscape-remix-01jvwb8ycyeansm83mthe31aqc.png',
                    alignment: Alignment(0, -0.9),
                    fit: BoxFit.cover,
                  ),
                ),
                SimpleElegantVintageFooter(), // Assuming this is defined elsewhere
              ],
            );
          },
        ),
      ),
    );
  }
}

class OpenFeaturesWidget extends StatelessWidget {
  // Renamed from open_features
  OpenFeaturesWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight, // Added for consistency, though not heavily used yet
    required this.itemWidth,
    required this.text,
    required this.title,
    required this.url,
    required this.isMobile,
    required this.isTablet,
  });

  final double screenWidth;
  final double screenHeight;
  final double itemWidth;
  final String title;
  final String text;
  final String url;
  final bool isMobile;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    double lottieWidth;
    double titleFontSize;
    double textFontSize;

    if (isMobile) {
      lottieWidth = itemWidth * 0.4;
      titleFontSize = 20;
      textFontSize = 14;
    } else if (isTablet) {
      lottieWidth = itemWidth * 0.3;
      titleFontSize = 24;
      textFontSize = 16;
    } else {
      // Web
      lottieWidth =
          itemWidth * 0.25; // Lottie smaller relative to larger itemWidth
      titleFontSize = 28;
      textFontSize = 18;
    }
    lottieWidth = lottieWidth.clamp(80.0, 200.0); // Min/Max for Lottie

    // Replace \n with space for web/tablet for better flow, keep for mobile if desired
    // String formattedText = (isMobile) ? text : text.replaceAll('\n', ' ');
    // Or just let Text widget handle wrapping naturally
    String formattedText = text;

    Widget textContent = Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.lora(
            height: isMobile ? 1.5 : 1.8,
            fontSize: titleFontSize,
            fontWeight: FontWeight.w800,
            color: Colors.brown[900],
          ),
        ),
        SizedBox(height: 8),
        Text(
          formattedText,
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.lora(
            fontSize: textFontSize,
            height: 1.4,
            color: Colors.brown[900],
          ),
        ),
      ],
    );

    Widget lottieAnimation = Lottie.network(
      url,
      width: lottieWidth,
      height: lottieWidth * 0.8, // Aspect ratio for lottie
      fit: BoxFit.contain,
    );

    return Container(
      width: itemWidth,
      padding: EdgeInsets.symmetric(
        vertical: 15,
        horizontal: isMobile ? 10 : 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        // color: Colors.white.withOpacity(0.5) // Optional subtle background
      ),
      child:
          isMobile
              ? Column(
                // Stack on mobile
                mainAxisSize: MainAxisSize.min,
                children: [textContent, SizedBox(height: 15), lottieAnimation],
              )
              : Row(
                // Row for tablet/web
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: textContent),
                  SizedBox(width: 15),
                  lottieAnimation,
                ],
              ),
    );
  }
}

class FeaturesWidget extends StatelessWidget {
  // Renamed from features
  const FeaturesWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.itemWidth,
    required this.title,
    required this.icon,
    required this.isMobile,
    required this.isTablet,
  });

  final double screenWidth;
  final double screenHeight;
  final double itemWidth;
  final String title;
  final IconData icon;
  final bool isMobile;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    const Color vintageCream = Color(0xFFFAF0E6);
    const Color darkBrown = Color(0xFF5D4037);
    const Color accentBrown = Color(0xFF8D6E63);

    double iconSize;
    double titleFontSize;
    double containerHeight = screenHeight * 0.28;

    if (isMobile) {
      iconSize = itemWidth * 0.2; // Icon size relative to item width
      titleFontSize = itemWidth * 0.07;
      containerHeight =
          itemWidth * 1.1; // Make height proportional to width for mobile
    } else if (isTablet) {
      iconSize = itemWidth * 0.22;
      titleFontSize = itemWidth * 0.065;
      containerHeight = itemWidth * 0.8;
    } else {
      // Web
      iconSize = itemWidth * 0.25;
      titleFontSize = itemWidth * 0.06;
      containerHeight = itemWidth * 0.7;
    }
    iconSize = iconSize.clamp(30.0, 60.0); // Min/Max icon size
    titleFontSize = titleFontSize.clamp(12.0, 22.0); // Min/Max font size
    containerHeight = containerHeight.clamp(150.0, 300.0);

    return Container(
      width: itemWidth,
      height: containerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: vintageCream,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: accentBrown.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(3.0, 3.0),
            blurRadius: 8.0,
          ),
        ],
        image: DecorationImage(
          image: NetworkImage('https://i.postimg.cc/q72yXVQN/88628.jpg'),
          fit: BoxFit.cover,
          opacity: 0.08, // Very subtle texture
          colorFilter: ColorFilter.mode(
            vintageCream.withOpacity(0.5),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: darkBrown),
          SizedBox(height: screenHeight * 0.015),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: darkBrown,
              letterSpacing: 0.5,
            ),
            maxLines: isMobile ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Keep your popularbooks widget as is, since it wasn't part of the layout changes requested
class popularbooks extends StatelessWidget {
  const popularbooks({
    super.key,
    required this.screenHeight,
    required this.name,
  });
  final String name;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    BooksInfo booksInfo = BooksInfo();
    Future<List> _bookInfo() async {
      return await booksInfo.getBookInfo(name);
    }

    Future<List> book = _bookInfo();

    return Expanded(
      child: Container(
        //height: screenHeight * 0.66,
        child: FutureBuilder(
          future: book,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data found'));
            } else {
              Map _book = snapshot.data![0];
              int coverId = _book['cover_i'] ?? 0;
              if (coverId == 0) {
                return Center(child: Text('No cover image available'));
              }
              String cover = coverId.toString();
              return Column(
                children: [
                  Column(
                    children: [
                      Image.network(
                        'https://covers.openlibrary.org/b/id/$cover-M.jpg', // Example JPG
                        fit: BoxFit.contain,
                        //width: double.infinity,
                        //height: screenHeight * 0.55,
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

// Ensure you have these classes defined or imported correctly:
// - SimpleElegantVintageFooter
// - BooksInfo (and its getBookInfo method)
// Also, ensure 'lib/images/final chill.png' asset exists.
