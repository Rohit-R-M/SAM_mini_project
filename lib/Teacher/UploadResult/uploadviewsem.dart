import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SemwiseResult extends StatefulWidget {
  const SemwiseResult({super.key});

  @override
  State<SemwiseResult> createState() => _SemwiseResultState();
}

class _SemwiseResultState extends State<SemwiseResult> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchCoursesByTeacher() async {
    User? user = _auth.currentUser;
    if (user != null) {
      print("Current User ID: ${user.uid}"); // Debug logging to check user ID
      DocumentSnapshot snapshot =
      await _firestore.collection('Admin_added_Course').doc(user.uid).get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        print("Fetched Document Data: $data"); // Debug logging to check fetched data
        String? instructorId = data['instructor_id'];
        String? branchName = data['branch_name'];

        if (instructorId == null || branchName == null) {
          print("Missing required fields in the document.");
          return [];
        }

        QuerySnapshot fetch = await _firestore
            .collection('Teacher_users')
            .where('branch', isEqualTo: branchName)
            .where('instructor_id', isEqualTo: instructorId)
            .get();

        return fetch.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      } else {
        print("User document does not exist in 'Admin_added_Course' collection.");
      }
    } else {
      print("No user is currently logged in.");
    }
    return [];
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
          "Semesters",
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
                        color: Colors.blue[50],
                        child: ListTile(
                          title: Text(
                            course['course_name'] ?? 'Unnamed Course',
                            style: TextStyle(fontFamily: 'Nexa'),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                course['course_instructor'] ?? 'Course Instructor',
                                style: TextStyle(
                                  fontFamily: 'NexaBold',
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                course['semester'] ?? 'Semester',
                                style: TextStyle(
                                  fontFamily: 'NexaBold',
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
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
