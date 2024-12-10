import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sam_pro/Teacher/UploadResult/uploadmarks.dart';

import 'package:sam_pro/Teacher/UploadResult/reports.dart';

class UploadViewStudent extends StatefulWidget {
  final String semester;
  final String courseName;

  const UploadViewStudent({super.key, required this.semester, required this.courseName});

  @override
  State<UploadViewStudent> createState() => _UploadViewStudentState();
}

class _UploadViewStudentState extends State<UploadViewStudent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          "Students",
          style: TextStyle(fontFamily: "Nexa", color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('Student_users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              var semester5students = snapshot.data!.docs.where((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return data['semester'] == widget.semester;
              }).toList();

              if (semester5students.isEmpty) {
                return Center(
                  child: Text("No students found"),
                );
              }

              return ListView.builder(
                itemCount: semester5students.length,
                itemBuilder: (context, index) {
                  var students = semester5students[index].data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left: 10, right: 10),
                        leading: CircleAvatar(
                          child: Text(students['name'][0]),
                        ),
                        title: Text(
                          students['name'] ?? 'No Name',
                          style: TextStyle(fontFamily: "Nexa"),
                        ),
                        subtitle: Text(
                          students['id'] ?? 'No ID',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "NexaBold",
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                        onTap: () {
                          // Pass both name and student ID to Exams screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UploadMarks(
                                studentName: students['name'] ?? 'No name',
                                studentID: students['id'] ?? 'No ID', // Pass the student ID
                                semester: widget.semester,
                                courseName: widget.courseName,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Reports(
                  semester: widget.semester,
                  courseName: widget.courseName,
                )));
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Report",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}