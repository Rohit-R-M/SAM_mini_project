import 'package:flutter/material.dart';
import 'package:sam_pro/Student/notification.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        title: Text(
          "Profile",
          style: TextStyle(fontFamily: 'Nexa'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => notificationscreen(), // Ensure this class is defined correctly
                ),
              );
            },
            icon: Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
    );
  }
}