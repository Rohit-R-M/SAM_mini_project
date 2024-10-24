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
        }, icon: Icon(Icons.arrow_back_ios)),
        title: const Text(
          "Attendance",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => notificationscreen(),));
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: Divider(
        thickness: 3,
        endIndent: 10,
        indent: 10,
      ),
    );
  }
}
