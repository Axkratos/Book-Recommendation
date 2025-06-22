import 'dart:async';
import 'dart:convert';
import 'package:bookrec/provider/authprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- State Variables ---
  String _userName = "";
  String _userBio = "";
  bool _isBioLoading = true;

  // TODO: Replace with your actual base URL and token retrieval logic
  final String _baseUrl = dotenv.env['baseUrl']!;

  @override
  void initState() {
    super.initState();
    UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    _fetchProfile(userProvider.token);
  }

  // --- Fetch Profile from API ---
  Future<void> _fetchProfile(String _token) async {
    setState(() {
      _isBioLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/api/v1/books/profile"),
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "success") {
          setState(() {
            _userName = data["data"]["fullName"] ?? "";
            _userBio = data["data"]["bio"] ?? "";
            _isBioLoading = false;
          });
        } else {
          setState(() {
            _userBio = "Failed to load profile.";
            _isBioLoading = false;
          });
        }
      } else {
        setState(() {
          _userBio = "Failed to load profile.";
          _isBioLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _userBio = "Error loading profile.";
        _isBioLoading = false;
      });
    }
  }

  // --- UI Logic ---
  void _showUpdateNameDialog() {
    final nameController = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFFF8E1),
          title: Text(
            'Update Your Name',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4E342E),
            ),
          ),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Enter your name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.amber),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.deepOrange,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey[700]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  UserProvider userProvider = Provider.of<UserProvider>(
                    context,
                    listen: false,
                  );
                  final success = await _updateUserName(
                    nameController.text,
                    userProvider.token,
                  );
                  if (success) {
                    // Refresh profile info after update
                    await _fetchProfile(userProvider.token);
                  }
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Add this method to your _ProfilePageState class
  Future<bool> _updateUserName(String newName, String token) async {
    final url = Uri.parse("$_baseUrl/api/v1/books/profile/fullname");
    try {
      final response = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"fullName": newName}),
      );
      if (response.statusCode == 200) {
        // Optionally handle response data if needed
        return true;
      }
    } catch (e) {
      // Optionally handle error
    }
    return false;
  }

  Future<void> _regenerateBio(String token) async {
    setState(() {
      _isBioLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/api/v1/books/profile/regenerate"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      print('Response from regenerate bio: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "success") {
          setState(() {
            _userName = data["data"]["fullName"] ?? _userName;
            _userBio = data["data"]["bio"] ?? _userBio;
            _isBioLoading = false;
          });
        } else {
          setState(() {
            _userBio = "Failed to regenerate bio.";
            _isBioLoading = false;
          });
        }
      } else {
        setState(() {
          _userBio = "Failed to regenerate bio.";
          _isBioLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _userBio = "Error regenerating bio.";
        _isBioLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE7),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Container(
            margin: EdgeInsets.all(isMobile ? 8.0 : 24.0),
            padding: EdgeInsets.all(isMobile ? 14.0 : 32.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade200, Colors.deepOrange.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isMobile ? 14.0 : 24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildProfileAvatar(isMobile: isMobile),
                SizedBox(height: isMobile ? 14 : 24),
                _buildUserInfo(isMobile: isMobile),
                SizedBox(height: isMobile ? 18 : 32),
                _buildActionButtons(isMobile: isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar({bool isMobile = false}) {
    return CircleAvatar(
      radius: isMobile ? 38 : 60,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person_outline_rounded,
        size: isMobile ? 44 : 70,
        color: const Color(0xFFEF6C00),
      ),
    );
  }

  Widget _buildUserInfo({bool isMobile = false}) {
    return Column(
      children: [
        // User Name
        Text(
          _userName,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 20 : 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4E342E),
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        // Bio Section with Animation
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child:
              _isBioLoading
                  ? _buildLoadingIndicator(isMobile: isMobile)
                  : Text(
                    _userBio,
                    key: ValueKey<String>(_userBio),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 13.5 : 16,
                      color: const Color(0xFF5D4037),
                      height: 1.5,
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator({bool isMobile = false}) {
    return SizedBox(
      height: isMobile ? 48 : 72,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildActionButtons({bool isMobile = false}) {
    if (isMobile) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: _showUpdateNameDialog,
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Update Name'),
            style: _buttonStyle(isMobile: true),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              UserProvider userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              _regenerateBio(userProvider.token);
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh Bio'),
            style: _buttonStyle(isMobile: true),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _showUpdateNameDialog,
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Update Name'),
            style: _buttonStyle(),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              UserProvider userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              _regenerateBio(userProvider.token);
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh Bio'),
            style: _buttonStyle(),
          ),
        ],
      );
    }
  }

  ButtonStyle _buttonStyle({bool isMobile = false}) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white.withOpacity(0.8),
      foregroundColor: const Color(0xFFEF6C00),
      elevation: 5,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: isMobile ? 10 : 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 20.0 : 30.0),
      ),
      textStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: isMobile ? 14 : null,
      ),
    );
  }
}
