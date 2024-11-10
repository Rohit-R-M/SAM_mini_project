import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeacherViewCourse extends StatefulWidget {
  const TeacherViewCourse({super.key});

  @override
  State<TeacherViewCourse> createState() => _TeacherViewCourseState();
}

class _TeacherViewCourseState extends State<TeacherViewCourse> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        title: Text(
          "Course Allocated",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Nexa',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Admin_added_Course').orderBy('semester').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No courses allocated."));
          }

          final courses = snapshot.data!.docs;
          Map<String, Map<String, List<DocumentSnapshot>>> branchWiseSemesterCourses = {};

          for (var course in courses) {
            String branch = course['branch'] ?? 'Unknown Branch';
            String semester = course['semester'] ?? 'Unknown Semester';

            branchWiseSemesterCourses.putIfAbsent(branch, () => {});
            branchWiseSemesterCourses[branch]!.putIfAbsent(semester, () => []);
            branchWiseSemesterCourses[branch]![semester]!.add(course);
          }

          return ListView(
            children: branchWiseSemesterCourses.keys.map((branch) {
              return ExpansionTile(
                title: Text(
                  branch,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nexa',
                  ),
                ),
                children: branchWiseSemesterCourses[branch]!.keys.map((semester) {
                  return ExpansionTile(
                    title: Text("Semester $semester"),
                    children: branchWiseSemesterCourses[branch]![semester]!.map((course) {
                      var courseName = course['course_name'] ?? 'Unknown Course';
                      var courseInst = course['course_instructor'] ?? 'N/A';

                      return ListTile(
                        title: Text(
                          courseName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nexa',
                          ),
                        ),
                        subtitle: Text("Instructor: $courseInst"),
                      );
                    }).toList(),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),

    );
  }
}

