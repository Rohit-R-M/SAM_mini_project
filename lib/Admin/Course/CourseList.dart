import 'package:flutter/material.dart';

class AdminCourseList extends StatefulWidget {
  const AdminCourseList({super.key});

  @override
  State<AdminCourseList> createState() => _AdminCourseListState();
}

class _AdminCourseListState extends State<AdminCourseList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        backgroundColor: Colors.blueAccent,
        title: Text("Course Allocated", style: TextStyle(fontWeight: FontWeight.bold,
            fontFamily: 'Nexa',
            color: Colors.white)),
        centerTitle: true,

      ),
    );
  }
}
