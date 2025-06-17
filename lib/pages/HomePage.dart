import 'package:bookrec/components/title.dart';
import 'package:bookrec/provider/authprovider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bookrec/pages/FeaturedPage.dart';
import 'package:provider/provider.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF6F2EA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF6F2EA),
        toolbarHeight: screenHeight * 0.09,
        elevation: 1,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.04,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// --- Left: BookRec logo ---
                GestureDetector(
                  onTap: () {
                    context.go('/');
                    // Navigate to the home page
                  },
                  child: title(),
                ),

                /// --- Center: Search Bar ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 40,
                      // Wrap TextField with GestureDetector for tap action
                      child: TextField(
                        onSubmitted: (value) {
                          context.go('/search/$value');
                        },
                        style: GoogleFonts.literata(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search books, authors, genres...',
                          hintStyle: GoogleFonts.literata(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[700],
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                /// --- Right: Buttons ---
                Row(
                  children: [
                    //_topButton(FontAwesomeIcons.solidStar, 'Like you', context),
                    //_topButton(FontAwesomeIcons.robot, 'Ai', context),
                    _signupButton(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: child,
    );
  }
}

Widget _topButton(IconData icon, String label, BuildContext context) {
  return TextButton.icon(
    onPressed: () {
      context.go('/mood');
    },
    icon: Icon(icon, size: 18, color: Colors.purple[700]),
    label: Text(
      label,
      style: GoogleFonts.literata(fontSize: 16, color: Colors.purple[700]),
    ),
  );
}

Widget _signupButton(BuildContext context) {
  final ProviderUser = Provider.of<UserProvider>(context);

  return GestureDetector(
    onTap: () {
      if (ProviderUser.getToken == '') {
        context.go('/signin');
      } else {
        context.go('/dashboard/home');
      }
    },
    child: Container(
      margin: EdgeInsets.only(left: 8),
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color.fromARGB(255, 224, 223, 130),
      ),
      child: Center(
        child: Row(
          children: [
            Icon(Icons.plus_one, size: 16),
            SizedBox(width: 4),
            Text(
              ProviderUser.getToken == '' ? 'Sign In' : 'Dashboard',
              style: GoogleFonts.literata(
                fontSize: 16,
                color: Colors.purple[700],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
