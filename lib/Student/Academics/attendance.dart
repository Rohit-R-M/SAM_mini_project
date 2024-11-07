import 'package:flutter/material.dart';
import 'package:sam_pro/Student/notification.dart';

class attendancescreen extends StatefulWidget {
  const attendancescreen({super.key});

  @override
  State<attendancescreen> createState() => _attendancescreenState();
}

class _attendancescreenState extends State<attendancescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Attendance",
          style:
          TextStyle(fontSize: 25, fontFamily: "Nexa", color: Colors.white),
        ),
        centerTitle: true,
      ),
    );
  }
}
