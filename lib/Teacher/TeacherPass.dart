import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeacherForgotPassword extends StatefulWidget {
  const TeacherForgotPassword({super.key});

  @override
  State<TeacherForgotPassword> createState() => _TeacherForgotPasswordState();
}

class _TeacherForgotPasswordState extends State<TeacherForgotPassword> {
  final _emailController = TextEditingController();
  final _reset = FirebaseAuth.instance;

  Future<void> forgotpassword() async {

    try{
      if(_emailController.text.trim().isNotEmpty){
        await _reset.sendPasswordResetEmail(email: _emailController.text.toString());

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Reset Password link is sent to your email"))
        );
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Enter the Valid E-mail ID")));
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios)),
        title: Text("Reset Password"),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Divider(
            indent: 10,
            endIndent: 10,
            thickness: 3,
          ),
          SizedBox(height: 20,),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.mail_outline),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                label: Text("Email"),
              ),
            ),
          ),
          SizedBox(height: 20,),

          ElevatedButton(onPressed: (){
            forgotpassword();
          }, child: Text("Reset Password"))
        ],
      ),
    );
  }
}

