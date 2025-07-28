
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../try.dart';
import 'admin_add.dart';



class admin_main extends StatefulWidget {
  const admin_main({super.key});

  @override
  State<admin_main> createState() => _admin_mainState();
}

class _admin_mainState extends State<admin_main> {
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

  int MyIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final logoSize = screenWidth * 0.08;
    final titleFontSize = screenWidth * 0.05;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: screenHeight * 0.11,
            title: Row(
              children: [
                // Logo and title section
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "asset/logo.png",
                        height: logoSize,
                        width: logoSize,
                      ),
                      const SizedBox(width: 8),
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
                // Logout button
                ElevatedButton.icon(
                  onPressed: _isLoggingOut ? null : _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                  icon: _isLoggingOut
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.logout, size: 16),
                  label: Text(_isLoggingOut ? "Logging out..." : "Logout"),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              SizedBox(
                width: screenWidth * 0.90,
                height: screenHeight * 0.05,
              ),
              Center(
                child: SizedBox(
                  width: screenWidth * 0.90,
                  height: screenHeight * 0.20,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const admin_add()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        "add project",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.04,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}