import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCourseList extends StatefulWidget {
  const AdminCourseList({super.key});

  @override
  State<AdminCourseList> createState() => _AdminCourseListState();
}

class _AdminCourseListState extends State<AdminCourseList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addOrUpdateCourse({DocumentSnapshot? course}) async {
    final courseNameController = TextEditingController(text: course?['course_name'] ?? '');
    final courseInstController = TextEditingController(text: course?['course_instructor'] ?? '');
    final courseInstidController = TextEditingController(text: course?['instructor_id'] ?? '');


    String branch = course?['branch'] ?? '';
    String _selectedSem = course?['semester'] ?? '';


    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Course', style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Nexa',
              ),),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: courseNameController,
                        decoration: InputDecoration(labelText: 'Course Name'),
                      ),
                      TextField(
                        controller: courseInstController,
                        decoration: InputDecoration(labelText: 'Course Instructor'),
                      ),
                      TextField(
                        controller: courseInstidController,
                        decoration: InputDecoration(labelText: 'Course Instructor Id'),
                      ),

                      SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Select the Semester',
                          labelStyle: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
                        ),
                        value: _selectedSem.isEmpty ? null : _selectedSem,
                        items: ['1', '2', '3', '4', '5', '6', '7', '8']
                            .map((String option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ))
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedSem = newValue!;
                          });
                        },
                      ),
                      SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Select a Branch',
                          labelStyle: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
                        ),
                        value: branch.isEmpty ? null : branch,
                        items: [
                          "Computer Science & Engineering",
                          'Information Science & Engineering',
                          'Civil Engineering',
                          "Mechanical Engineering",
                          "Electrical Engineering",
                          "Electronics & Communication Engineering",
                          "Biotechnology Engineering"
                        ]
                            .map((String option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ))
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            branch = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final data = {
                      'course_name': courseNameController.text,
                      'course_instructor': courseInstController.text,
                      'instructor_id': courseInstidController.text,
                      'semester': _selectedSem,
                      'branch': branch,
                    };
                    if (course == null) {
                      await _firestore.collection('Admin_added_Course').add(data);
                    } else {
                      await course.reference.update(data);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(course == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteCourse(DocumentSnapshot course) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Remove Course",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Nexa',
            ),
          ),
          content: Text(
            "Are you sure you want to remove this course?",
            style: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900)),
            ),
            ElevatedButton(
              onPressed: () async {
                await course.reference.delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Course removed successfully')),
                );
              },
              child: Text(
                "Remove",
                style: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

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
                      var courseInstid = course['instructor_id'] ?? 'N/A';

                      return ListTile(
                        title: Text(
                          courseName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nexa',
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Instructor: $courseInst"),
                            Text("ID: $courseInstid"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () => _addOrUpdateCourse(course: course),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteCourse(course),
                            ),
                          ],
                        ),
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
