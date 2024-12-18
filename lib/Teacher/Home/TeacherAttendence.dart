import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sam_pro/Teacher/Attendance/Teacheraddattemdance.dart';
import 'package:sam_pro/Teacher/UploadResult/uploadviewstud.dart';
class Semesterscreen extends StatefulWidget {
  final String name;
  final String id;

  const Semesterscreen({super.key, required this.name, required this.id}); // Accept name and id as parameters

  @override
  State<Semesterscreen> createState() => _SemwiseResultState();
}

class _SemwiseResultState extends State<Semesterscreen> {
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchCoursesByTeacher() async {
    // Retrieve all documents in the Admin_added_Course collection
    QuerySnapshot querySnapshot = await _firestore.collection('Admin_added_Course').get();

    // Filter documents based on the provided instructor_id and branch
    List<Map<String, dynamic>> matchingCourses = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Check if document fields match the passed instructor_id and branch
      if (data['instructor_id'] == widget.id && data['course_instructor'] == widget.name) {
        matchingCourses.add(data); // Add the matching document to the list
      }
    }
    return matchingCourses;
  }

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
        backgroundColor: Colors.blueAccent,
        title: Text(
          "Subjects",
          style: TextStyle(fontFamily: 'Nexa', color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 450,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchCoursesByTeacher(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No courses found for this teacher.'));
                }

                List<Map<String, dynamic>> courses = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.separated(
                    itemCount: courses.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> course = courses[index];
                      return Container(

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue[50],
                        ),
                        child: ListTile(
                          title: Text(
                            course['course_name'] ?? 'Unnamed Course',
                            style: TextStyle(fontFamily: 'Nexa'),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Semester: ${course['semester'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontFamily: 'NexaBold',
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>AttendancePage(
                              semester:course['semester'] ?? 'N/A',
                              courseName:course['course_name'] ?? 'N/A',
                              id:widget.id,
                              name:widget.name,
                            )));
                          },
                          trailing: Icon(Icons.arrow_forward_ios,color: Colors.black,),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        color: Colors.blue[200],
                        thickness: 1.0,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}