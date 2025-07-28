import 'package:demo/project_trying/Log_in.dart';
import 'package:demo/project_trying/admin_main.dart';
import 'package:demo/project_trying/admin_product_card.dart';
import 'package:demo/project_trying/home.dart';
import 'package:demo/project_trying/product_card.dart';
import 'package:demo/project_trying/try_regi.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';


void main()  async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized
//   await Firebase.initializeApp(); // Then initialize Firebase
//   runApp(MyApp()); // Start your app
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: admin_product_card(),
    );
  }
}