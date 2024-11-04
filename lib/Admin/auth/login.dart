import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sam_pro/Admin/Home/Homepage.dart';



class adminlogin extends StatefulWidget {
  const adminlogin({super.key});

  @override
  State<adminlogin> createState() => _adminloginState();
}

class _adminloginState extends State<adminlogin> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adminidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  bool _isLoading = false;

  final _adminid = 'admin123';
  final _adminpass = 'admin123';

  void _login() {
    setState(() {
      _isLoading = true;
    });
    if (_adminid == _adminidController.text && _adminpass == _passwordController.text) {

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => adminhomepage(),),);

      // TODO: Add actual authentication logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful')),
      );
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed!")),
      );
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
                    "Admin Login!",
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
                    controller: _adminidController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.perm_identity, color: Colors.blueGrey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      labelText: "Admin Id",
                      labelStyle: TextStyle(color: Colors.blueGrey[500]),
                    ),
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
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => StudentForgotPassword(),));
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
                    child: _isLoading ? CircularProgressIndicator():ElevatedButton(
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

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
