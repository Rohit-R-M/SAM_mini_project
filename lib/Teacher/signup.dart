import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sam_pro/Teacher/login.dart';

class TeacherSignUpScreen extends StatefulWidget {
  const TeacherSignUpScreen({super.key});

  @override
  State<TeacherSignUpScreen> createState() => _TeacherSignUpScreenState();
}

class _TeacherSignUpScreenState extends State<TeacherSignUpScreen> {


  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phonenoController = TextEditingController();

  bool _isPasswordVisible = false;

  bool _isLoading = false;

  FirebaseAuth _auth = FirebaseAuth.instance;

  final  _firebaseDatabase = FirebaseDatabase.instance.ref('Teacher_list');
  final _firebasefirestore = FirebaseFirestore.instance.collection('Teacher_list');
  final _getTeacherData = FirebaseDatabase.instance.ref().child('Admin_Teachers_List');



  void _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final String uniqueId = _idController.text.trim().toUpperCase();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String phoneNo = _phonenoController.text.trim();

    try {
      final DataSnapshot snapshot = await _getTeacherData.get();
      bool isMatch = false;


      //Main Loop of the program
      for (var teacher in snapshot.children) {

        final teacherdata = teacher.value as Map<Object?, Object?>?;

        if (teacherdata != null) {
          final Map<String, dynamic> typedData = teacherdata.map(
                (key, value) => MapEntry(key as String, value as dynamic),
          );

          final storedId = typedData['id'] as String?;
          final storedEmail = typedData['email'] as String?;

          if (storedId != null && storedEmail != null && storedId == uniqueId && storedEmail == email) {
            isMatch = true;
            break;
          }
        }
      }



      if (isMatch) {
        await _auth.createUserWithEmailAndPassword(email: email, password: password);

        await _firebaseDatabase.child(uniqueId).set({
          'usn': uniqueId,
          'email': email,
          'phone_no': phoneNo,
          'password': password,
        });

        await _firebasefirestore.doc(uniqueId).set({
          'usn': uniqueId,
          'email': email,
          'phone_no': phoneNo,
          'password': password,
        });



        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TeacherLoginScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SignUp Successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your ID and Email don't exist!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SignUp Failed!!')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  void dispose() {
    // Dispose controllers to free resources
    _idController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phonenoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Form(
        key: _formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 250,
                    child: Lottie.asset('assets/images/animation/Animation - 1730444855525.json'),
                  ),

                  Text(
                    "Create an Account!",
                    style: GoogleFonts.qwitcherGrypen(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 45,
                        color: Colors.blueGrey[900],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    "Please enter your credentials to continue",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey[700],
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _idController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.perm_identity, color: Colors.blueGrey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      labelText: "Unique Id",
                      labelStyle: TextStyle(color: Colors.blueGrey[500]),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Unique Id';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
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

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _phonenoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.phone, color: Colors.blueGrey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      labelText: "Phone No",
                      labelStyle: TextStyle(color: Colors.blueGrey[500]),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Phone number';
                      }
                      if (value.length==10)
                      {
                        return 'Enter Valid Phone number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),


                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.lock, color: Colors.blueGrey[500]),
                      suffixIcon: IconButton(
                        icon: Icon( _isPasswordVisible ? Icons.visibility : Icons.visibility_off,color: Colors.blueGrey[500],),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.blueGrey[500]),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child:_isLoading?Center(child: CircularProgressIndicator()):ElevatedButton(
                      onPressed: () {
                        _signup();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blueGrey[800],
                      ),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.blueGrey[700]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TeacherLoginScreen()),
                          );
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
