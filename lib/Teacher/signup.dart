import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final TextEditingController _confirmpasswordController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phonenoController = TextEditingController();

  bool _isPasswordVisible = false;

  bool _isLoading = false;

  FirebaseAuth _auth = FirebaseAuth.instance;

  final  _firebaseDatabase = FirebaseDatabase.instance.ref('Teacher_list');
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
      //end of Main loop of the program


      if (isMatch) {
        await _auth.createUserWithEmailAndPassword(email: email, password: password);

        await _firebaseDatabase.child(uniqueId).set({
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
    return Container(
      child: Scaffold(
        appBar:PreferredSize(
          preferredSize: const Size.fromHeight(200), // Custom height
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),


            child: AppBar(
              leading: IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
              backgroundColor: Colors.blueAccent,
              elevation: 8, // Adds subtle shadow

              flexibleSpace: Container(
                alignment: Alignment.center, // Center the title
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Teacher Sign Up',
                      style: GoogleFonts.qwitcherGrypen(
                        textStyle:TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Create your account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
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

                  //username
                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'Unique Id',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your UniqueId';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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

                  const SizedBox(height: 16),

                  //phone number
                  TextFormField(
                    controller: _phonenoController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Phone number';
                      }
                      if (value.length>9 && value.length<9)
                      {
                        return 'Enter Valid Phone number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon( !_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
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


                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _confirmpasswordController,
                    keyboardType: TextInputType.text,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirm-Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon( !_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      } if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  Container(
                    child: _isLoading ? CircularProgressIndicator() :
                    ElevatedButton(
                      onPressed:_signup,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.blueAccent)
                        ),
                      ),
                      child: const Text('Sign up', style: TextStyle(fontSize: 18,color: Colors.blueAccent)),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey, // Line color
                          thickness: 2,       // Line thickness
                          endIndent: 10,      // Space at the end of the divider
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "OR",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey, // Line color
                          thickness: 2,       // Line thickness
                          indent: 10,         // Space at the start of the divider
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  TextButton(onPressed: (){
                    Navigator.pop(context);
                  }, child:  Text("Already have an Account? Login",style: TextStyle(fontSize: 15)),)
                ],
              ),
            ),
          ),
        ),

      ),
    );
  }
}
