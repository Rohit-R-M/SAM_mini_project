import 'dart:async';

import 'package:animated_splash_screen/animated_splash_screen.dart';
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
          
              Text("Sam Project",
                style: GoogleFonts.qwitcherGrypen(
                    textStyle: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )
                ),
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
/*


*return Scaffold(
      body: Container(
        color: Colors.blueAccent,

        child: Stack(

          children: [
            // Center Text
            Align(
              alignment: Alignment.center,
              child: Text("Sam Project",
                style: GoogleFonts.qwitcherGrypen(
                    textStyle: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )
                ),
              ),
            ),
            // Bottom Center Text
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                // Optional padding
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1,color: Colors.white),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Developed by BEC CSE',
                      style: TextStyle(fontSize: 12,color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    }
    }*/