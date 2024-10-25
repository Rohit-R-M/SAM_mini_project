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
        }, icon: Icon(Icons.arrow_back_ios)),
        title: const Text(
          "Exam",
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
      body: const Divider(
        thickness: 3,
        endIndent: 10,
        indent: 10,
      ),
    );
  }
}
