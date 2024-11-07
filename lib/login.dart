import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sam_pro/StudPass.dart';
import 'package:sam_pro/Student/homepage.dart';
import 'package:sam_pro/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  FirebaseAuth _auth = FirebaseAuth.instance;

  final _getStudentData = FirebaseDatabase.instance.ref().child('Admin_Students_List');

  bool _isLoading = false;

  bool isMatch = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final email =  _emailController.text.trim();

    if (_formKey.currentState!.validate()) {
      try{
        final DataSnapshot snapshot = await _getStudentData.get();

        for (var student in snapshot.children) {

          final studentData = student.value as Map<Object?, Object?>?;

          if (studentData != null) {
            final Map<String, dynamic> typedData = studentData.map(
                  (key, value) => MapEntry(key as String, value as dynamic),
            );
            final storedEmail = typedData['email'] as String?;

            if (storedEmail != null && storedEmail == email) {
              isMatch = true;
              break;
            }
          }
        }

        if(isMatch){

          await _auth.signInWithEmailAndPassword(
              email: _emailController.text.toString(),
              password: _passwordController.text.toString());

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage(),),);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Successful!')),
          );
        }else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Your Email don't exist!")),
          );
        }

      }on FirebaseAuthException catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message??'Login Failed'))
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
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
                  Container(
                    height: 300,
                    child: Lottie.asset('assets/images/animation/Animation - 1730444923074.json'),
                  ),

                  SizedBox(height: 20),

                  Text(
                    "Student Login!",
                    style: GoogleFonts.qwitcherGrypen(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 45,
                        color: Colors.blueGrey[900],
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                  Text(
                    "Please login to continue",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey[700],
                    ),
                  ),

                  SizedBox(height: 30),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
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

                  SizedBox(height: 20),

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

                  SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => StudentForgotPassword(),));
                      },
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(color: Colors.blueGrey[700]),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: _isLoading ? Center(child: CircularProgressIndicator()):ElevatedButton(
                      onPressed: () {
                         _login();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blueGrey[800],
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account?",
                        style: TextStyle(color: Colors.blueGrey[700]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => signupscreen(),));
                        },
                        child: Text(
                          "Sign Up",
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