import 'package:flutter/material.dart';

class notificationscreen extends StatefulWidget {
  const notificationscreen({super.key});

  @override
  State<notificationscreen> createState() => _notificationscreenState();
}

class _notificationscreenState extends State<notificationscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios)),
        title: const Text(
          "Notifications",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(" Here are the Notifications"),
      ),
    );
  }
}
