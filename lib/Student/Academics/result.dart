import 'package:flutter/material.dart';
import 'package:sam_pro/Student/notification.dart';

class resultscreen extends StatefulWidget {
  const resultscreen({super.key});

  @override
  State<resultscreen> createState() => _resultscreenState();
}

class _resultscreenState extends State<resultscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Result",
          style:
          TextStyle(fontSize: 25, fontFamily: "Nexa", color: Colors.white),
        ),
        centerTitle: true,
      ),
    );
  }
}
