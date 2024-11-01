import 'dart:async';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sam_pro/Student/homepage.dart';
import 'package:sam_pro/rolescreen.dart';


class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  State<splashscreen> createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen> {

  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _currentuser();
  }

  Future<void> _currentuser() async {

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(days: 1)); // Simulate some delay.

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(),),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => rolescreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splash:  SingleChildScrollView(
          child: Column(
            children: [
              Lottie.asset('assets/images/animation/Animation - 1730330845060.json'),

              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    "Sam Project!",
                    textStyle: GoogleFonts.qwitcherGrypen(fontSize: 60.0, fontWeight: FontWeight.bold,color: Colors.white),
                    speed: Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
                pause: Duration(milliseconds: 1000),
              ),
            ],
          ),
        ),
          nextScreen: rolescreen(),
      duration: 3000,
      backgroundColor: Colors.blueAccent,
      splashIconSize: 400,
    );
  }
}