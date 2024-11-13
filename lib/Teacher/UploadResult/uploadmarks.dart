import 'package:flutter/material.dart';
import 'package:sam_pro/Teacher/UploadResult/uploadassignment.dart';
import 'package:sam_pro/Teacher/UploadResult/uploadcie1.dart';
import 'package:sam_pro/Teacher/UploadResult/uploadcie2.dart';

class UploadMarks extends StatelessWidget {

  final String studentName;
  final String studentID;  // Add studentID as a parameter

  const UploadMarks({super.key, required this.studentName, required this.studentID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exams"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Display the student's name above the list
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '$studentName',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          // List of exams
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.book),
                  title: Text("CIE-1"),
                  onTap: () {
                    // Pass the studentID to Cie1Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Cie1Screen(
                          title: "CIE-1",
                          studentID: studentID,  // Pass the studentID here
                        ),
                      ),
                    );
                  },
                ),
                Divider(thickness: 2),
                ListTile(
                  leading: Icon(Icons.book),
                  title: Text("CIE-2"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Cie2Screen(
                          title: "CIE-2",
                          studentID: studentID,  // Pass the studentID here
                        ),
                      ),
                    );
                  },
                ),
                Divider(thickness: 2),
                ListTile(
                  leading: Icon(Icons.book),
                  title: Text("Assignment"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignmentScreen(
                          title: "assigment",
                          studentID: studentID,
                        ),
                      ),
                    );
                  },
                ),
                Divider(thickness: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}