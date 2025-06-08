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

  final _formKey = GlobalKey<FormState>();
  Authservice _authservice = Authservice();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final ProviderUser = Provider.of<UserProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: purpleAccent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            alignment: Alignment.topCenter,
            scale: 3.0,
            image: AssetImage('lib/images/signin.png'),
            fit:
                BoxFit
                    .contain, // Use BoxFit.contain to fit the image within the container
          ),
        ),
        child: Center(
          child: Container(
            height: screenHeight * 0.7,
            width: screenWidth * 0.25,
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
                    //SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Personalize your experience and books:>',
                      style: vintageLabelStyle,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    signupTextFormField(
                      screenWidth: screenWidth,
                      icon: Icons.email,
                      hintText: 'Enter your email',
                      controller: _email,
                      validator: (value) {
                        if (value == null || value!.isEmpty) {
                          return 'Please full the form';
                        } else if (!value.contains('@') ||
                            !value.contains('.')) {
                          return 'Please fill the form correctly';
                        }
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    signupTextFormField(
                      passwordVisible: true,
                      screenWidth: screenWidth,
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
                    VintageButton(
                      text: 'Sign In',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (_) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            );
                            print('Pressed Submit on Sign In');
                            final response = await _authservice
                                .sendLoginRequest(_email.text, _password.text);
                            Navigator.pop(context);

                            if (response['status'] == 'success') {
                              ProviderUser.setToken = response['token'];
                              context.go('/dashboard/home');
                            } else if (response['status'] == 'failed') {
                              setState(() {
                                errorMessage =
                                    'An error occurred. Please try again.';
                              });
                            }

                            print(response);
                          } catch (e) {
                            Navigator.pop(context);
                            setState(() {
                              errorMessage =
                                  'An error occurred. Please try again.';
                            });
                          } finally {
                            //Navigator.pop(context);
                          }
                        }

                        //context.go('/dashboard/home');
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
                      height: screenHeight * 0.2,
                      width: screenWidth * 0.15,
                      fit: BoxFit.cover,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Dont have accout?', style: vintageTextStyle),
                        TextButton(
                          onPressed: () {
                            // Navigate to login page
                            context.go('/signin/signup');
                          },
                          child: Text(
                            'Sign Up',
                            style: vintageMenuTextStyle.copyWith(
                              color: Colors.blue,
                              decoration:
                                  TextDecoration
                                      .underline, //fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
      width: screenWidth * 0.2,
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
        onChanged: (value) {
          //print('Search query: $value');
        },
        validator: (value) => validator(value),
      ),
    );
  }
}
