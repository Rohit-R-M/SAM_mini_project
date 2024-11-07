import 'package:flutter/material.dart';
import 'package:sam_pro/Student/notification.dart';

class calenderscreen extends StatefulWidget {
  const calenderscreen({super.key});

  @override
  State<calenderscreen> createState() => _calenderscreenState();
}

class _calenderscreenState extends State<calenderscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Calendar",
          style:
          TextStyle(fontSize: 25, fontFamily: "Nexa", color: Colors.white),
        ),
        centerTitle: true,
      ),
    );
  }
}
