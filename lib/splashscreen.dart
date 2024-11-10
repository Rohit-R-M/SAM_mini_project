import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sam_pro/Student/homepage.dart';
import 'package:sam_pro/Teacher/Home/home.dart';
import 'package:sam_pro/rolescreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference fetch = FirebaseFirestore.instance.collection('Student_users');
  User? _user;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    _user = _auth.currentUser;

    Timer(const Duration(seconds: 5), () async {
      if (_user != null) {
        print("User is logged in: ${_user!.uid}");
        try {
          final docSnapshot = await fetch.doc(_user!.uid).get();
          if (docSnapshot.exists) {
            final role = docSnapshot.get('role');
            print("User role: $role");

            if (mounted) {
              if (role == 'Student') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              } else  {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) =>  HomeContent()),
                );
              }
            }
          } else {
            print("Document does not exist for user: ${_user!.uid}");
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Rolescreen()),
              );
            }
          }
        } catch (e) {
          print("Error retrieving role: $e");
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Rolescreen()),
            );
          }
        }
      } else {
        print("No user is logged in.");
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Rolescreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                double scale = 0.5 + _controller.value * 0.7;
                return Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    height: 300,
                    child: Lottie.asset('assets/images/animation/booksanima.json'),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              "Sam Project",
              style: GoogleFonts.qwitcherGrypen(
                textStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 60,
                  color: Colors.blueGrey[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
