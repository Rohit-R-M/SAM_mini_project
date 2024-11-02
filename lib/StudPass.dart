import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StudentForgotPassword extends StatefulWidget {
  const StudentForgotPassword({super.key});

  @override
  State<StudentForgotPassword> createState() => _StudentForgotPasswordState();
}

class _StudentForgotPasswordState extends State<StudentForgotPassword> {
  final _emailController = TextEditingController();
  final _reset = FirebaseAuth.instance;
  bool _isloading = false;

  Future<void> forgotpassword() async {
    setState(() {
      _isloading = true;
    });
    try {
      if (_emailController.text.trim().isNotEmpty) {
        await _reset.sendPasswordResetEmail(email: _emailController.text.toString());

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Reset Password link is sent to your email")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Enter a valid E-mail ID")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blueGrey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[800]!, Colors.blueGrey[400]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animation
                  Container(
                    height: 250,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Lottie.asset('assets/images/animation/Animation - 1730503315147.json'),
                  ),

                  SizedBox(height: 20),

                  // Card container for form
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Email field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              prefixIcon: Icon(Icons.email, color: Colors.blueGrey[500]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              labelText: "Email",
                              labelStyle: TextStyle(color: Colors.blueGrey[500]),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 20),

                          // Reset button with loading indicator
                          SizedBox(
                            width: double.infinity,
                            child: _isloading
                                ? Center(child: CircularProgressIndicator(color: Colors.blueGrey[800]))
                                : ElevatedButton(
                              onPressed: () {
                                forgotpassword();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.blueGrey[800],
                              ),
                              child: Text(
                                "Reset Password",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
