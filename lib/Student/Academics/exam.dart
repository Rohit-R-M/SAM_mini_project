import 'package:flutter/material.dart';
import 'package:sam_pro/Student/notification.dart';

class examscreen extends StatefulWidget {
  const examscreen({super.key});

  @override
  State<examscreen> createState() => _examscreenState();
}

class _examscreenState extends State<examscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Exam",
          style:
          TextStyle(fontSize: 25, fontFamily: "Nexa", color: Colors.white),
        ),
        centerTitle: true,
      ),
    );
  }
}
