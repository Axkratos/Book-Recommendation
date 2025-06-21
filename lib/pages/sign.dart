import 'package:bookrec/components/VintageButton.dart';
import 'package:bookrec/components/title.dart';
import 'package:bookrec/provider/authprovider.dart';
import 'package:bookrec/services/authservice.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/texts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String errorMessage = '';
  bool isLoading = false; // Add this line

  final _formKey = GlobalKey<FormState>();
  Authservice _authservice = Authservice();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final ProviderUser = Provider.of<UserProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Responsive width and height
    double containerWidth;
    double containerHeight;
    double formFieldWidth;
    double imageHeight;
    double imageWidth;

    if (screenWidth >= 1200) {
      // Desktop
      containerWidth = screenWidth * 0.25;
      containerHeight = screenHeight * 0.75;
      formFieldWidth = screenWidth * 0.2;
      imageHeight = screenHeight * 0.2;
      imageWidth = screenWidth * 0.15;
    } else if (screenWidth >= 800) {
      // Laptop/Tablet Landscape
      containerWidth = screenWidth * 0.45;
      containerHeight = screenHeight * 0.7;
      formFieldWidth = screenWidth * 0.4;
      imageHeight = screenHeight * 0.18;
      imageWidth = screenWidth * 0.25;
    } else if (screenWidth >= 600) {
      // Tablet Portrait
      containerWidth = screenWidth * 0.6;
      containerHeight = screenHeight * 0.7;
      formFieldWidth = screenWidth * 0.7;
      imageHeight = screenHeight * 0.15;
      imageWidth = screenWidth * 0.4;
    } else {
      // Mobile
      containerWidth = screenWidth * 0.9;
      containerHeight = screenHeight * 0.75;
      formFieldWidth = screenWidth * 0.9;
      imageHeight = screenHeight * 0.12;
      imageWidth = screenWidth * 0.6;
    }

    return Scaffold(
      backgroundColor: purpleAccent,
      body: Container(
        decoration: BoxDecoration(
          image:
              screenWidth > 600
                  ? DecorationImage(
                    alignment: Alignment.topCenter,
                    scale: 3.0,
                    image: AssetImage('lib/images/signin.png'),
                    fit: BoxFit.contain,
                  )
                  : null, // Hide background image on small screens
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              height: containerHeight,
              width: containerWidth,
              decoration: BoxDecoration(
                color: appBarColor,
                border: Border.all(width: 2, color: vintageBorderColor),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      title(),
                      Text(
                        'Personalize your experience and books:>',
                        style: vintageLabelStyle,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      signupTextFormField(
                        screenWidth: formFieldWidth,
                        icon: Icons.email,
                        hintText: 'Enter your email',
                        controller: _email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please fill the form';
                          } else if (!value.contains('@') ||
                              !value.contains('.')) {
                            return 'Please fill the form correctly';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      signupTextFormField(
                        passwordVisible: true,
                        screenWidth: formFieldWidth,
                        icon: Icons.password,
                        hintText: 'Enter your password',
                        controller: _password,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      isLoading
                          ? CircularProgressIndicator() // Show loader when loading
                          : VintageButton(
                            text: 'Sign In',
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                try {
                                  print('Pressed Submit on Sign In');
                                  final response = await _authservice
                                      .sendLoginRequest(
                                        _email.text,
                                        _password.text,
                                      );
                                  setState(() {
                                    isLoading = false;
                                  });

                                  if (response['status'] == 'success') {
                                    ProviderUser.setToken = response['token'];
                                    context.go('/dashboard/home');
                                  } else if (response['status'] == 'failed') {
                                    print(
                                      'Login failed: ${response['status']}',
                                    );
                                    if (response['verification'] == true) {
                                      print('Email not verified');
                                      context.go('/signin/signup/verify');
                                    }

                                    setState(() {
                                      errorMessage = '${response['message']}';
                                    });
                                  }

                                  print(response);
                                } catch (e) {
                                  print('Error during login: $e');
                                  setState(() {
                                    isLoading = false;
                                    errorMessage =
                                        'An error occurred. Please try again.';
                                  });
                                }
                              }
                            },
                          ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        errorMessage,
                        style: GoogleFonts.literata(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      Image.asset(
                        'lib/images/book-shelf.png',
                        height: imageHeight,
                        width: imageWidth,
                        fit: BoxFit.cover,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account?',
                            style: vintageTextStyle,
                          ),
                          TextButton(
                            onPressed: () {
                              context.go('/signin/signup');
                            },
                            child: Text(
                              'Sign Up',
                              style: vintageMenuTextStyle.copyWith(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigates to /signin/forgot-password
                          context.go('/signin/forgot-password');
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class signupTextFormField extends StatelessWidget {
  signupTextFormField({
    super.key,
    required this.screenWidth,
    required this.icon,
    required this.hintText,
    required this.controller,
    this.passwordVisible = false,
    required this.validator,
  });
  final IconData icon;
  final String hintText;
  final bool passwordVisible;
  final String? Function(String?) validator;

  final double screenWidth;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth,
      child: TextFormField(
        controller: controller,
        obscureText: passwordVisible ? true : false,
        style: GoogleFonts.literata(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.literata(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(icon, color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          contentPadding: EdgeInsets.symmetric(horizontal: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) => validator(value),
      ),
    );
  }
}
