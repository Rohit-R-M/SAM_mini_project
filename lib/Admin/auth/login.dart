import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sam_pro/Admin/Home/Homepage.dart';
import 'package:sam_pro/rolescreen.dart';


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
      appBar:PreferredSize(
        preferredSize: const Size.fromHeight(200), // Custom height
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),


          child: AppBar(
            leading: IconButton(onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => rolescreen(),));
            }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)
            ),
            backgroundColor: Colors.blueAccent,
            elevation: 8, // Adds subtle shadow
            flexibleSpace: Container(
              alignment: Alignment.center, // Center the title
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text('Admin Login',
                    style: GoogleFonts.qwitcherGrypen(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Text("Enter your Credentials to Login",style: TextStyle(color: Colors.white,fontSize: 15),),
                ],
              ),
            ),
          ),
        ),
      ),


      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(

              children: [

                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _adminidController,
                  decoration: const InputDecoration(
                    labelText: 'Admin ID',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.perm_identity),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter the Admin Id';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: !_isPasswordVisible,
                  decoration:InputDecoration(

                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon( _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
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
                
                const SizedBox(height: 5),
                
                Container(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: (){}, child: Text("Forgot Password?"))),
                ),
                
                const SizedBox(height: 12),

                // Login Button
                Container(
                  child: _isLoading ? CircularProgressIndicator() :
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 18,color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 22),

                    Divider(
                        color: Colors.grey, // Line color
                        thickness: 2,       // Line thickness
                        endIndent: 10,      // Space at the end of the divider
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
