import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added Firebase Auth import
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Cloud Firestore import
import 'package:firebase_core/firebase_core.dart';

import 'Log_in.dart';




class try_regi extends StatefulWidget {
  const try_regi({super.key});

  @override
  State<try_regi> createState() => _try_regiState();
}

class _try_regiState extends State<try_regi> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _cityName = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false; // Add loading state

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = false;
  }

  // Move the register function outside initState and make it properly async
  Future<void> register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        // Debug: Print values to console
        print('Starting registration...');
        print('Email: ${_emailController.text.trim()}');
        print('Username: ${_usernameController.text.trim()}');
        print('Phone: ${_phoneNumber.text.trim()}');
        print('City: ${_cityName.text.trim()}');

        // Check if Firebase is initialized
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp();
          print('Firebase initialized');
        }

        // Create user with email and password
        print('Creating user with Firebase Auth...');
        final UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        print('User created with UID: ${userCredential.user!.uid}');

        // Store additional user data in Firestore
        print('Storing user data in Firestore...');
        await FirebaseFirestore.instance.collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailController.text.trim(),
          'username': _usernameController.text.trim(),
          'phonenumber': _phoneNumber.text.trim(),
          'city': _cityName.text.trim(),
          'password': _passwordController.text.trim(), // Store password
          'uid': userCredential.user!.uid,
          'createdAt': FieldValue.serverTimestamp(), // Add timestamp
        });

        print('User data stored successfully in Firestore');

        // Clear form fields
        _emailController.clear();
        _passwordController.clear();
        _usernameController.clear();
        _phoneNumber.clear();
        _cityName.clear();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful! User data saved to Firebase.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to login screen after successful registration
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Log_in()),
        );

      } on FirebaseAuthException catch (e) {
        // Handle specific Firebase Auth errors
        print('FirebaseAuthException: ${e.code} - ${e.message}');
        String message;
        if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          message = 'The account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          message = 'The email address is not valid.';
        } else if (e.code == 'network-request-failed') {
          message = 'Network error. Please check your internet connection.';
        } else {
          message = e.message ?? 'An unknown error occurred.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      } on FirebaseException catch (e) {
        // Handle Firestore specific errors
        print('FirebaseException: ${e.code} - ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firestore error: ${e.message}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } catch (e) {
        // Handle other general errors
        print('General error: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    } else {
      print('Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final logoSize = screenWidth * 0.08;
    final titleFontSize = screenWidth * 0.05;
    final cardMargin = EdgeInsets.symmetric(horizontal: screenWidth * 0.12, vertical: screenHeight * 0.03);
    final formPadding = EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.03);
    final headingFontSize = screenWidth * 0.035;
    final buttonFontSize = screenWidth * 0.02;
    final spacingHeight = screenHeight * 0.02;
    final textFieldHeight = screenHeight * 0.08;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          toolbarHeight: screenHeight * 0.11,
          title: Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(screenWidth * 0.35, 0, 0, 0),
              child: Row(
                children: [
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
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: cardMargin,
            child: Card(
              elevation: 15,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: const Color(0xFF1F346B),
              child: Padding(
                padding: formPadding,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: spacingHeight),
                      Text(
                        'Register Here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: headingFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: spacingHeight * 1.5),

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        hint: "Enter your Email",
                        icon: Icons.email_outlined,
                        screenHeight: textFieldHeight,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z]+\.[a-zA-Z]{2,}$");
                          if (!emailRegex.hasMatch(value)) {
                            return 'Invalid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: spacingHeight),

                      // Username
                      _buildTextField(
                        controller: _usernameController,
                        hint: "Enter your Username",
                        icon: Icons.verified_user_sharp,
                        screenHeight: textFieldHeight,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          final usernameRegex = RegExp(r"^[A-Za-z][A-Za-z0-9_]{3,29}$");
                          if (!usernameRegex.hasMatch(value)) {
                            return 'Invalid username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: spacingHeight),

                      // Phone number
                      _buildTextField(
                        controller: _phoneNumber,
                        hint: "Enter your Phone Number",
                        icon: Icons.phone,
                        screenHeight: textFieldHeight,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your number';
                          }
                          final phoneRegex = RegExp(r"^[0-9]{10}$");
                          if (!phoneRegex.hasMatch(value)) {
                            return 'Invalid phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: spacingHeight),

                      // City
                      _buildTextField(
                        controller: _cityName,
                        hint: "Enter your City",
                        icon: Icons.location_city,
                        screenHeight: textFieldHeight,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your city';
                          }
                          final cityRegex = RegExp(r'^[A-Za-z]{3,29}$');
                          if (!cityRegex.hasMatch(value)) {
                            return 'Invalid city name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: spacingHeight),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
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

                      SizedBox(height: spacingHeight * 1.5),

                      TextFormField(
                        controller: _confirmPassword,
                        decoration: InputDecoration(
                          hintText: "Confirm your password",
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
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
                            return 'Please match your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: spacingHeight * 1.5),

                      // Register Button
                      SizedBox(
                        height: textFieldHeight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.01,
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
                          onPressed: _isLoading ? null : register, // Call the register function and disable button during loading
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.025,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  Log_in()),
                              );
                            },
                            child: Text(
                              'Log in',
                              style: TextStyle(
                                color: Colors.lightBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.025,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required double screenHeight,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return SizedBox(
      height: screenHeight,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _phoneNumber.dispose();
    _cityName.dispose();
    super.dispose();
  }
}