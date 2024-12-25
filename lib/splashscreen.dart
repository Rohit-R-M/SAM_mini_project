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
  final CollectionReference fetch = FirebaseFirestore.instance.collection('Admin_Students_List');
  final CollectionReference tfetch = FirebaseFirestore.instance.collection('Admin_Teachers_List');
  User? _user;

  @override
  void initState() {
    super.initState();

    _user = _auth.currentUser;

    Timer(const Duration(seconds: 3), () async {
      if (_user != null) {
        try {
          final docSnapshot = await fetch.doc(_user!.uid).get();

          if (docSnapshot.exists) {
            final role = docSnapshot.get('role');

            if (role == 'student') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            }
          } else {
            // Document doesn't exist for either student or teacher
            print("No document found for user: ${_user!.uid}");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Rolescreen()),
            );
          }
        } catch (e) {
          print("Error retrieving role: $e");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Rolescreen()),
          );
        }
      } else {
        print("No user is logged in.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Rolescreen()),
        );
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
      body:  Center(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipOval(
                child: SizedBox(
                  height: 150,
                  width: 150,
                  child: Image.asset('assets/images/Splash1.png', fit: BoxFit.cover),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "from",
                      style: TextStyle(
                        fontFamily: "Nexa",
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "BEC CSE",
                      style: TextStyle(
                        fontFamily: "Nexa",
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}