import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:itbs__express/admin/home_admin.dart';
import 'package:itbs__express/pages/buttom_nav.dart';
import 'package:itbs__express/pages/home.dart';
import 'package:itbs__express/pages/login.dart';
import 'package:itbs__express/pages/onBoard.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ITBS Express',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: Onboard(),
    );
  }
}
