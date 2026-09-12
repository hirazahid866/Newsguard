import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }



  void _validateName(String value) {
    final name = value.trim();

    if (name.isEmpty) {
      _nameError = "Full Name is required";
    } else if (!RegExp(r'^[a-zA-Z][a-zA-Z\s]*$').hasMatch(name)) {
      _nameError = "Full Name can contain letters only";
    } else {
      _nameError = null;
    }
  }



  void _validateEmail(String value) {
    final email = value.trim();

    if (email.isEmpty) {
      _emailError = "Email is required";
    } else if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email)) {
      _emailError = "Enter a valid email address";
    } else {
      _emailError = null;
    }
  }



  void _validatePassword(String value) {
    if (value.isEmpty) {
      _passwordError = "Password is required";
    } else if (value.length < 8) {
      _passwordError =
      "Password must be at least 8 characters";
    } else if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'[0-9]').hasMatch(value) ||
        !RegExp(
          r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]]',
        ).hasMatch(value)) {
      _passwordError =
      "Password must contain letters, numbers and 1 special"
          " character";
    } else {
      _passwordError = null;
    }
  }



  void _validateConfirmPassword(String value) {
    if (value.isEmpty) {
      _confirmPasswordError =
      "Confirm Password is required";
    } else if (value != _password.text) {
      _confirmPasswordError =
      "Passwords do not match";
    } else {
      _confirmPasswordError = null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFA0F9FF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [


                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Sign up to get started",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),



                    TextField(
                      controller: _name,
                      onChanged: (value) {

                        if (_nameError != null) {
                          setState(() {
                            _nameError = null;
                          });
                        }
                      },
                      decoration: _inputDecoration(
                        "Full Name",
                        errorText: _nameError,
                      ),
                    ),

                    const SizedBox(height: 16),



                    TextField(
                      controller: _email,
                      keyboardType:
                      TextInputType.emailAddress,
                      onChanged: (value) {

                        if (_emailError != null) {
                          setState(() {
                            _emailError = null;
                          });
                        }
                      },
                      decoration: _inputDecoration(
                        "Email Address",
                        errorText: _emailError,
                      ),
                    ),

                    const SizedBox(height: 16),



                    TextField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      onChanged: (value) {

                        if (_passwordError != null) {
                          setState(() {
                            _passwordError = null;
                          });
                        }


                        if (_confirmPasswordError != null &&
                            _confirmPassword.text.isNotEmpty) {
                          setState(() {
                            _confirmPasswordError = null;
                          });
                        }
                      },
                      decoration: _inputDecoration(
                        "Password",
                        errorText: _passwordError,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                              !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),



                    TextField(
                      controller: _confirmPassword,
                      obscureText: _obscureConfirmPassword,
                      onChanged: (value) {
                        // Typing ke waqt validation nahi hogi
                        if (_confirmPasswordError != null) {
                          setState(() {
                            _confirmPasswordError = null;
                          });
                        }
                      },
                      decoration: _inputDecoration(
                        "Confirm Password",
                        errorText:
                        _confirmPasswordError,
                        suffix: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),



                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _signup,
                        child: const Text("Sign Up"),
                      ),
                    ),

                    const SizedBox(height: 24),


                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text:
                          "Already have an account? ",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration:
                                TextDecoration.underline,
                                color: Colors.black,
                              ),
                              recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const LoginScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  InputDecoration _inputDecoration(
      String hint, {
        Widget? suffix,
        String? errorText,
      }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      suffixIcon: suffix,
      errorText: errorText,


      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),


      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),


      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),


      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),

      errorStyle: const TextStyle(
        color: Colors.red,
        fontSize: 12,
      ),
    );
  }


  Future<void> _signup() async {


    setState(() {
      _validateName(_name.text);
      _validateEmail(_email.text);
      _validatePassword(_password.text);
      _validateConfirmPassword(_confirmPassword.text);
    });


    if (_nameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    try {


      final User? user =
      await _auth.createUserWithEmailAndPassword(
        _email.text.trim(),
        _password.text,
      );

      if (!mounted) return;

      if (user != null) {


        await user.updateDisplayName(
          _name.text.trim(),
        );

        if (!mounted) return;


        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'provider': 'email',
          'createdAt': DateTime.now(),
          'lastLogin': DateTime.now(),
        });

        if (!mounted) return;

        log("User Created Successfully");



        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User Created Successfully"),
            duration: Duration(seconds: 1),
          ),
        );



        await Future.delayed(
          const Duration(seconds: 1),
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
    }



    on FirebaseAuthException catch (e) {
      if (!mounted) return;

      log("Signup Firebase Error: ${e.code}");

      if (e.code == 'email-already-in-use') {
        setState(() {
          _emailError = "Email is already registered";
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          _emailError =
          "Enter a valid email address";
        });
      } else if (e.code == 'weak-password') {
        setState(() {
          _passwordError =
          "Password is too weak";
        });
      }
    }


    catch (e) {
      log("Signup error: $e");
    }
  }
}
