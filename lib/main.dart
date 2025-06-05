import 'package:e_pass_app/screens/splashScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Passbook',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}

/* 
🎯 FOR TEAM DEMO:
To switch between versions, only modify the splashScreen.dart file:

In splashScreen.dart, find the _navigateToLogin() method and change:

ORIGINAL VERSION:
Navigator.pushReplacement(context, PageRouteBuilder(...LoginScreen()...));

BANKING VERSION (for demo):
Navigator.pushReplacement(context, PageRouteBuilder(...LoginBankingScreen()...));

That's it! Your main.dart stays untouched.
*/
