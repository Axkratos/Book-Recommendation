// dashboard_page.dart
import 'package:bookrec/pages/emotion_chat.dart';
import 'package:bookrec/provider/authprovider.dart';
import 'package:bookrec/theme/color.dart'; // Your color definitions
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;

void navigateToReactPage() {
  html.window.location.href = 'https://example.com/react-page';
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _activeIndex = 0;
  // --- Step 2: Remove the state variable that is now in ChatWidget ---
  // bool _isChatOpen = false; // <-- REMOVED

  int _getIndexFromRoute(String location) {
    if (location.startsWith('dashboard/home')) return 0;
    if (location.startsWith('/dashboard/shelf')) return 1;
    if (location.startsWith('/dashboard/discussion')) return 2;
    if (location.startsWith('/dashboard/trending')) return 3;
    if (location.startsWith('/dashboard/profile')) return 5;
    return 0; // default fallback
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location =
        GoRouter.of(context).routeInformationProvider.value.location;
    final index = _getIndexFromRoute(location);
    if (_activeIndex != index) {
      setState(() {
        _activeIndex = index;
      });
    }
  }

  // Helper method to build menu items
  Widget _buildMenuItem({
    required IconData icon,
    required String tooltip,
    required int index,
  }) {
    final ProviderUser = Provider.of<UserProvider>(context);

    bool isActive = _activeIndex == index;
    return Tooltip(
      message: tooltip,
      textStyle: GoogleFonts.ebGaramond(color: vintageCream, fontSize: 14),
      decoration: BoxDecoration(
        color: vintageDarkBrown.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      preferBelow: false, // Show tooltip to the side
      child: Material(
        color: Colors.transparent, // Important for InkWell splash
        child: InkWell(
          onTap: () {
            setState(() {
              _activeIndex = index;
              switch (index) {
                case 0:
                  context.go('/dashboard/home'); // Home
                  break;
                case 1:
                  context.go('/dashboard/shelf'); // Shelf
                  break;
                case 2:
                  context.go('/dashboard/discussion'); // Discussions
                  break;
                case 3:
                  context.go('/dashboard/trending');
                  break; // Trending
                case 4:
                  context.go('/ebook'); // Reader
                  break;
                case 5:
                  context.go('/dashboard/profile'); // Reader
                  break;
                case 6:
                  ProviderUser.logout(); // Logout
                  context.go('/'); // Redirect to sign-in page
                  break;
              }
            });
            print("$tooltip tapped");
          },
          borderRadius: BorderRadius.circular(8), // For splash effect
          hoverColor: vintageActiveIconColor.withOpacity(0.1),
          splashColor: vintageActiveIconColor.withOpacity(0.2),
          child: Container(
            padding: const EdgeInsets.all(12), // Padding around the icon
            decoration: BoxDecoration(
              color:
                  isActive
                      ? vintageActiveIconColor.withOpacity(0.15)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border:
                  isActive
                      ? Border.all(color: vintageActiveIconColor, width: 1.5)
                      : Border.all(color: Colors.transparent, width: 1.5),
            ),
            child: Icon(
              icon,
              color: isActive ? vintageActiveIconColor : vintageIconColor,
              size: 28, // Slightly smaller for a more refined look
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double sidebarWidth =
        screenWidth * 0.08 < 100 ? 100 : screenWidth * 0.08;

    Widget sidebar = Container(
      width: sidebarWidth,
      height: screenHeight,
      decoration: BoxDecoration(
        color: vintageSidebarBg,
        boxShadow: [
          BoxShadow(
            color: vintageBorderColor.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: FaIcon(
                FontAwesomeIcons.bookBookmark,
                color: vintageCream.withOpacity(0.7),
                size: 35,
              ),
            ),
            _buildMenuItem(
              icon: FontAwesomeIcons.house,
              tooltip: "Home",
              index: 0,
            ),
            SizedBox(height: screenHeight * 0.015),
            _buildMenuItem(
              icon: FontAwesomeIcons.layerGroup,
              tooltip: "Shelf",
              index: 1,
            ),
            SizedBox(height: screenHeight * 0.015),
            _buildMenuItem(
              icon: FontAwesomeIcons.users,
              tooltip: "Discussions",
              index: 2,
            ),
            _buildMenuItem(
              icon: FontAwesomeIcons.fire,
              tooltip: 'Trending',
              index: 3,
            ),
            _buildMenuItem(
              icon: FontAwesomeIcons.readme,
              tooltip: "Reader",
              index: 4,
            ),
            _buildMenuItem(
              icon: FontAwesomeIcons.user,
              tooltip: "Profile",
              index: 5,
            ),
            const Spacer(),
            _buildMenuItem(
              icon: FontAwesomeIcons.rightFromBracket,
              tooltip: "Logout",
              index: 6,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: vintageCream,
      drawer:
          screenWidth < 700
              ? Drawer(
                backgroundColor:
                    Colors.transparent, // <-- Make Drawer transparent
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: SizedBox(width: 220, child: sidebar),
                  ),
                ),
              )
              : null,
      body: Stack(
        children: [
          Row(
            children: [
              if (screenWidth >= 700) sidebar,
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.04,
                  ),
                  child: widget.child,
                ),
              ),
            ],
          ),
        ],
      ),
      appBar:
          screenWidth < 700
              ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: vintageDarkBrown),
              )
              : null,
    );
  }

  // --- Step 4: Remove the build methods for the chat bubble and window ---
  // _buildChatBubble() and _buildChatWindow() have been REMOVED
}

// You can remove the old dashboard_menu class if you adopt the _buildMenuItem helper
// class dashboard_menu extends StatelessWidget {
//   const dashboard_menu({super.key, required this.icon});
//   final IconData icon;

//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       onPressed: () {},
//       icon: Icon(icon, color: vintageDarkBrown, size: 35),
//     );
//   }
// }
