import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../try.dart';
import 'AppBarExample.dart';
import 'BottomNavExample.dart';



class trying_home extends StatefulWidget {
  const trying_home({super.key});

  @override
  State<trying_home> createState() => _trying_homeState();
}

class _trying_homeState extends State<trying_home> {
  bool _isLoggingOut = false;

  // Simple logout function
  Future<void> _logout() async {
    // Show confirmation dialog
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      setState(() {
        _isLoggingOut = true;
      });

      try {
        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();

        // Navigate to login page immediately after signout
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Logggg()),
                (route) => false,
          );
        }
      } catch (e) {
        // Handle logout error
        if (mounted) {
          setState(() {
            _isLoggingOut = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;



    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBarExample(screenWidth: screenWidth, screenHeight: screenHeight, isLoggingOut: _isLoggingOut, onLogout: _logout),
        bottomNavigationBar: BottomNavExample(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Categories section
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                      child: Wrap(
                        spacing: screenWidth * 0.02,
                        runSpacing: screenHeight * 0.01,
                        children: List.generate(5, (index) {
                          return Card(
                            elevation: 15,
                            color: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(color: Colors.black),
                            ),
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Text(
                                  "Category ${index + 1}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: screenWidth * 0.04,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // Best deals section
              Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.03, 0, screenWidth * 0.03, 0),
                  child: Card(
                    elevation: 20,
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: Colors.black),
                    ),
                    child: Container(
                      width: screenWidth * 0.90,
                      height: screenHeight * 0.35,
                      alignment: Alignment.center,
                      child: Text(
                        "Best deals",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.06,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Products section
              _buildProductSection(screenWidth, screenHeight, "Products", Colors.lightGreenAccent),

              // Newly added section
              _buildProductSection(screenWidth, screenHeight, "Newly added", Colors.deepOrangeAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSection(double screenWidth, double screenHeight, String title, Color backgroundColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: screenWidth,
            height: screenHeight * 0.20,
            color: backgroundColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: List.generate(3, (index) {
                  return Container(
                    width: screenWidth * 0.36,
                    height: screenHeight * 0.18,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Card(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Product ${index + 1}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.04,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}