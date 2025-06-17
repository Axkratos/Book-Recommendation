import 'package:bookrec/components/VintageButton.dart';
import 'package:bookrec/components/drop_down_menu.dart';
import 'package:bookrec/components/title.dart';
import 'package:bookrec/services/authservice.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/texts.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _fname = TextEditingController();
  //TextEditingController _lname = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();
  Authservice _auth = Authservice();
  String errorMessage = 'Please fill all the fields correctly';

  DateTime? selectedDate;
  Future<void> selectDate(BuildContext context) async {
    final DateTime? dateTime = await showDatePicker(
      context: context,
      firstDate: DateTime(1985, 1, 1),
      lastDate: DateTime.now(),
    );

    if (dateTime != null) {
      setState(() {
        selectedDate = dateTime;
      });
    }
  }

  // Y
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    double containerWidth;
    double containerHeight;
    double formFieldWidth;
    double imageHeight;
    double imageWidth;

    if (screenWidth >= 1200) {
      // Desktop
      containerWidth = screenWidth * 0.3;
      containerHeight = screenHeight * 0.8;
      formFieldWidth = screenWidth * 0.2;
      imageHeight = screenHeight * 0.2;
      imageWidth = screenWidth * 0.15;
    } else if (screenWidth >= 800) {
      // Laptop/Tablet Landscape
      containerWidth = screenWidth * 0.5;
      containerHeight = screenHeight * 0.85;
      formFieldWidth = screenWidth * 0.4;
      imageHeight = screenHeight * 0.18;
      imageWidth = screenWidth * 0.25;
    } else if (screenWidth >= 600) {
      // Tablet Portrait
      containerWidth = screenWidth * 0.8;
      containerHeight = screenHeight * 0.9;
      formFieldWidth = screenWidth * 0.7;
      imageHeight = screenHeight * 0.15;
      imageWidth = screenWidth * 0.4;
    } else {
      // Mobile
      containerWidth = screenWidth * 0.9;
      containerHeight = screenHeight * 0.8;
      formFieldWidth = screenWidth * 0.95;
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
                    image: AssetImage('lib/images/signin.png'),
                    fit: BoxFit.cover,
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
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      signupTextFormField(
                        screenWidth: formFieldWidth,
                        icon: Icons.person,
                        hintText: 'Enter your full name',
                        controller: _fname,
                        onChanged: (value) {},
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      signupTextFormField(
                        screenWidth: formFieldWidth,
                        icon: Icons.email,
                        hintText: 'Enter your email',
                        controller: _email,
                        onChanged: (value) {
                          if (value.isEmpty || !value.contains('@')) {
                            setState(() {
                              errorMessage = 'Please enter a valid email';
                            });
                          } else {
                            setState(() {
                              errorMessage = '';
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!value.contains('@') ||
                              !value.contains('.')) {
                            return 'Please enter a valid email';
                          }
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      signupTextFormField(
                        screenWidth: formFieldWidth,
                        icon: Icons.password,
                        hintText: 'Enter your password',
                        controller: _password,
                        onChanged: (value) {
                          if (value.isEmpty || value.length < 6) {
                            setState(() {
                              errorMessage =
                                  'Password must be at least 6 characters';
                            });
                          } else {
                            setState(() {
                              errorMessage = '';
                            });
                          }
                        },
                        passwordVisible: true,
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
                      signupTextFormField(
                        screenWidth: formFieldWidth,
                        icon: FontAwesomeIcons.passport,
                        hintText: 'confirm password',
                        controller: _confirmPassword,
                        onChanged: (value) {
                          if (value != _password.text) {
                            setState(() {
                              errorMessage = 'Passwords do not match';
                            });
                          } else {
                            setState(() {
                              errorMessage = '';
                            });
                          }
                        },
                        passwordVisible: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          } else if (value != _password.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: screenHeight * 0.02),
                      VintageButton(
                        text: 'Sign up!',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            String fname = _fname.text;
                            //String lname = _lname.text;
                            String email = _email.text;
                            String password = _password.text;
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (_) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            );
                            try {
                              final message = await _auth.sendRegisterRequest(
                                fname,
                                //lname,
                                email,
                                password,
                              );
                              if (message == 'success') {
                                Navigator.of(context).pop(); // Close the dialog
                                context.go('/signin/signup/verify');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Registration successful!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                // Navigate to the home page or dashboard
                              } else {
                                setState(() {
                                  errorMessage = message;
                                });
                                Navigator.of(context).pop(); // Close the dialog
                              }
                            } catch (e) {
                              setState(() {
                                errorMessage =
                                    'An error occurred: ${e.toString()}';
                              });
                            } finally {
                              //Navigator.of(context).pop(); // Close the dialog
                            }
                            print('first name:$fname');
                            //context.push('/dashboard/home');
                          } else {
                            setState(() {
                              errorMessage =
                                  'Please fill all the fields correctly';
                            });
                            //return; // Exit if validation fails
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
                      // Optionally add an image for larger screens
                      if (screenWidth > 600)
                        Image.network(
                          'https://i.postimg.cc/sxL8XyzW/20250525-2217-3-D-Book-Collection-remix-01jw44ha01ejsvtx44vg3tnjm0.png',
                          height: imageHeight,
                          width: imageWidth,
                          fit: BoxFit.cover,
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
  const signupTextFormField({
    super.key,
    required this.screenWidth,
    required this.icon,
    required this.hintText,
    required this.controller,
    required this.onChanged,
    this.passwordVisible = false,
    required this.validator,
  });
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final bool passwordVisible;
  final String? Function(String?) validator;

  final double screenWidth;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth,
      child: TextFormField(
        keyboardType:
            passwordVisible
                ? TextInputType.visiblePassword
                : TextInputType.text,
        obscureText: passwordVisible ? true : false,
        controller: controller,
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
        onChanged: (value) {
          onChanged(value);
        },
        validator: validator,
      ),
    );
  }
}
