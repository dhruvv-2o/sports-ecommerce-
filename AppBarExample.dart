import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Log_in.dart';

class AppBarExample extends StatelessWidget implements PreferredSizeWidget {
  final double screenWidth;
  final double screenHeight;
  final bool isLoggingOut;
  final VoidCallback onLogout;

  const AppBarExample({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.isLoggingOut,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final logoSize = screenWidth * 0.08;
    final titleFontSize = screenWidth * 0.05;

    return AppBar(
      backgroundColor: Colors.black,
      toolbarHeight: screenHeight * 0.11,
      title: Row(
        children: [
          // Logo and title
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  "https://res.cloudinary.com/debdioyvy/image/upload/v1753083433/Final_Logo_qqkgm2.jpg",
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

          // Logout Button
          ElevatedButton.icon(
            onPressed: isLoggingOut ? null : onLogout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            icon: isLoggingOut
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.logout, size: 16),
            label: Text(isLoggingOut ? "Logging out..." : "Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(screenHeight * 0.11);
}
