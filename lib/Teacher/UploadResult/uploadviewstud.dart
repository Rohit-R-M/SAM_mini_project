import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sam_pro/Teacher/UploadResult/uploadmarks.dart';

class UploadViewStudent extends StatefulWidget {
  const UploadViewStudent({super.key});

  @override
  State<UploadViewStudent> createState() => _UploadViewStudentState();
}

class _UploadViewStudentState extends State<UploadViewStudent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Students"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Student_users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var semester5students = snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return data['semester'] == '5';
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
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Icon(Icons.school),
                    title: Text(students['name'] ?? 'No Name'),
                    subtitle: Text(
                      students['id'] ?? 'No id',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    ),
                    onTap: () {
                      // Pass both name and student ID to Exams screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadMarks(
                            studentName: students['name'] ?? 'No name',
                            studentID: students['id'] ?? 'No ID',  // Pass the student ID
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
    );
  }
}
