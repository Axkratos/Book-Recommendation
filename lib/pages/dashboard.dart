// dashboard_page.dart
import 'package:bookrec/provider/authprovider.dart';
import 'package:bookrec/theme/color.dart'; // Your color definitions
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _activeIndex = 0; // To keep track of the active icon

  int _getIndexFromRoute(String location) {
    if (location.startsWith('dashboard/home')) return 0;
    if (location.startsWith('/dashboard/shelf')) return 1;
    if (location.startsWith('/dashboard/discussion')) return 2;
    if (location.startsWith('/dashboard/trending')) return 3;
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
                  ProviderUser.logout(); // Logout
                  context.go('/'); // Redirect to sign-in page
                  break;
                case 5:
                  context.go('/reader'); // Trending
                  break; // Trending

                // Trending
              }
            });
            // Add navigation or action logic here
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

    // Define a fixed width for the sidebar, or a percentage that makes sense
    final double sidebarWidth =
        screenWidth * 0.08 < 100 ? 100 : screenWidth * 0.08;

    return Scaffold(
      backgroundColor: vintageCream,
      body: Row(
        children: [
          // Vintage Sidebar
          Container(
            width: sidebarWidth,
            height: screenHeight, // Make it full height
            decoration: BoxDecoration(
              color: vintageSidebarBg,
              boxShadow: [
                BoxShadow(
                  color: vintageBorderColor.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(2, 0), // changes position of shadow
                ),
              ],
              // Optional: Add a subtle border on the right
              // border: Border(
              //   right: BorderSide(color: vintageBorderColor.withOpacity(0.7), width: 1),
              // )
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Align to top
                children: [
                  // Optional: A placeholder for a logo or title
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: FaIcon(
                      FontAwesomeIcons.bookBookmark, // Example logo
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
                  // Changed icon
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
                  ), // Changed icon

                  const Spacer(), // Pushes logout to the bottom
                  _buildMenuItem(
                    icon: FontAwesomeIcons.rightFromBracket,
                    tooltip: "Logout",
                    index: 4,
                  ),
                  _buildMenuItem(
                    icon: FontAwesomeIcons.readme,
                    tooltip: "Reader",
                    index: 5,
                  ),
                ],
              ),
            ),
          ),
          // Main Content Area
          Expanded(
            child: Padding(
              // Keep original padding for content, or adjust as needed
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02,
                horizontal:
                    screenWidth * 0.04, // Reduced slightly due to sidebar
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
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
