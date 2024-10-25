import 'package:flutter/material.dart';
import 'package:sam_pro/Admin/auth/login.dart';
import 'package:sam_pro/Teacher/login.dart';
import 'package:sam_pro/login.dart';

class rolescreen extends StatefulWidget {
  const rolescreen({super.key});

  @override
  State<rolescreen> createState() => _rolescreenState();
}

class _rolescreenState extends State<rolescreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent,
      child: Center(
        child: Container(
          width: 300,
          height: 300,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: const [
             BoxShadow(
                  color: Colors.black38,
                spreadRadius: 5,
                blurRadius: 30
              )
            ]
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginPage()),);
                }, child: Text("Student",style: TextStyle(fontSize: 15),),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.blueAccent,width: 1.5)
                    )
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              SizedBox(
                width: 200,
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> TeacherLoginScreen()),);
                }, child: Text("Teacher",style: TextStyle(fontSize: 15),),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.blueAccent,width: 1.5),),
                    ),
                  ),
                ),

              const SizedBox(
                height: 20,
              ),


              SizedBox(
                width: 200,
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> adminlogin()),);
                }, child: Text("Admin",style: TextStyle(fontSize: 15),),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.blueAccent,width: 1.5),),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
