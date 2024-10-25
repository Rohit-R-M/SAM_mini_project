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
        }, icon: Icon(Icons.arrow_back_ios)),
        title: const Text(
          "Calendar",
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
