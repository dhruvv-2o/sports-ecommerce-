import 'package:demo/project_trying/try_regi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added Firebase Auth import
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home.dart'; // Added Cloud Firestore import

class Log_in extends StatefulWidget {
  const Log_in({super.key});

  @override
  State<Log_in> createState() => _Log_inState();
}

class _Log_inState extends State<Log_in> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false; // Added loading state
  bool _isCheckingAuth = true; // Added auth checking state

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = false;
    _checkAuthState(); // Check if user is already signed in
  }

  // Check if user is already authenticated
  void _checkAuthState() async {
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (mounted) {
        if (user != null) {
          // User is signed in, check if user data exists in Firestore
          try {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

            if (userDoc.exists) {
              // User exists in Firestore, navigate to home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => trying_home()),
              );
            } else {
              // User authenticated but no data in Firestore, sign out
              await FirebaseAuth.instance.signOut();
              setState(() {
                _isCheckingAuth = false;
              });
            }
          } catch (e) {
            // Error checking user data, stay on login screen
            setState(() {
              _isCheckingAuth = false;
            });
          }
        } else {
          // User is signed out, stay on login screen
          setState(() {
            _isCheckingAuth = false;
          });
        }
      }
    });
  }

  // Updated function to handle login instead of registration
  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        // Sign in with email and password
        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Check if user data exists in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          // User exists in Firestore, login successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login Successful!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigation will be handled by authStateChanges listener
          // No need to manually navigate here anymore
        } else {
          // User authenticated but no data in Firestore
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User data not found. Please contact support.'),
              backgroundColor: Colors.orange,
            ),
          );

          // Sign out the user since they don't have valid data
          await FirebaseAuth.instance.signOut();
        }
      } on FirebaseAuthException catch (e) {
        // Handle specific Firebase Auth errors
        String message;
        switch (e.code) {
          case 'user-not-found':
            message = 'No user found for that email.';
            break;
          case 'wrong-password':
            message = 'Wrong password provided for that user.';
            break;
          case 'invalid-email':
            message = 'The email address is not valid.';
            break;
          case 'user-disabled':
            message = 'This user account has been disabled.';
            break;
          case 'too-many-requests':
            message = 'Too many failed login attempts. Try again later.';
            break;
          case 'network-request-failed':
            message = 'Network error. Please check your connection.';
            break;
          default:
            message = "Invalid Username or Password" ?? 'An unknown error occurred.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      } catch (e) {
        // Handle other general errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final logoSize = screenWidth * 0.08;
    final titleFontSize = screenWidth * 0.05;

    // Show loading screen while checking auth state
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: screenHeight * 0.13,
        title: Padding(
          padding: EdgeInsets.fromLTRB(screenWidth * 0.35, 0, 0, 0),
          child: Row(
            children: [
              // Ensure 'asset/logo.png' exists in your pubspec.yaml assets
              Image.asset(
                "asset/logo.png",
                height: logoSize,
                width: logoSize,
              ),
              Text(
                "ATHLETIX",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: titleFontSize,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Center(
          child: Card(

            elevation: 15,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: const Color(0xFF1F346B),
            margin: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.05,
            ),
            child: Stack(
              children: [
                // If you uncomment this, ensure 'asset/Untitled design.png' exists
                // Image.asset("asset/Untitled design.png",
                //   fit: BoxFit.fitWidth,
                //   alignment: Alignment.center,
                // ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                    vertical: screenHeight * 0.05,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          'Welcome Back!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please login to your account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.02,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Email TextFormField
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: "Enter your Email",
                            prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password TextFormField
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: "Enter your password",
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02,
                              horizontal: screenWidth * 0.02,
                            ),
                            textStyle: TextStyle(
                              fontSize: screenWidth * 0.30,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 3,
                          ),
                          onPressed: _isLoading ? null : login, // Disable button when loading
                          child: _isLoading
                              ? SizedBox(
                            width: screenWidth * 0.04,
                            height: screenWidth * 0.04,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.025,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have account?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenWidth * 0.011,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const try_regi()),
                                );
                              },
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  color: Colors.lightBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.011,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}