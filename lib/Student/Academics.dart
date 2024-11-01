import 'package:flutter/material.dart';
import 'package:sam_pro/Student/Academics/attendance.dart';
import 'package:sam_pro/Student/Academics/exam.dart';
import 'package:sam_pro/Student/Academics/result.dart';
import 'package:sam_pro/Student/notification.dart';
import 'package:sam_pro/Student/Academics/calendar.dart';

class AcademicsScreen extends StatefulWidget {
  const AcademicsScreen({super.key});

  @override
  State<AcademicsScreen> createState() => _AcademicsScreenState();
}

class _AcademicsScreenState extends State<AcademicsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Academics",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => notificationscreen(),
                ),
              );
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),


      body:
      ListView(
        children: [
          const Divider(
            thickness: 3,
            indent: 10,
            endIndent: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const CircleAvatar(
                radius: 30,
                child: Icon(Icons.calendar_today),
              ),
              title: const Text(
                "Calendar",
                style: TextStyle(fontSize: 20),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => calenderscreen(),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const CircleAvatar(
                radius: 30,
                child: Icon(Icons.bookmark_add_outlined),
              ),
              title: const Text(
                "Attendance",
                style: TextStyle(fontSize: 20),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => attendancescreen(),));
              },
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const CircleAvatar(
                radius: 30,
                child: Icon(Icons.grade),
              ),
              title: const Text(
                "Result",
                style: TextStyle(fontSize: 20),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(context,MaterialPageRoute(builder:(context) => resultscreen(),)
                );
              },
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const CircleAvatar(
                radius: 30,
                child: Icon(Icons.list_alt),
              ),
              title: const Text(
                "Exam",
                style: TextStyle(fontSize: 20),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => examscreen(),));
              },
            ),
          ),
        ],
      ),
    );
  }
}
