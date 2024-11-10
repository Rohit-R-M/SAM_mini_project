import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentsList extends StatefulWidget {
  const StudentsList({super.key});

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          "Students List",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500, fontFamily: 'Nexa', color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Student_users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          final students = snapshot.data!.docs;

          // Group students by branch and semester
          final Map<String, Map<String, List<QueryDocumentSnapshot>>> branchSemesterGroups = {};

          for (var student in students) {
            final branch = student['branch_name'] ?? 'Unknown Branch';
            final semester = student['semester'] ?? 'Unknown Semester';

            if (!branchSemesterGroups.containsKey(branch)) {
              branchSemesterGroups[branch] = {};
            }
            if (!branchSemesterGroups[branch]!.containsKey(semester)) {
              branchSemesterGroups[branch]![semester] = [];
            }

            branchSemesterGroups[branch]![semester]!.add(student);
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: branchSemesterGroups.entries.map((branchEntry) {
              final branch = branchEntry.key;
              final semesterGroups = branchEntry.value;

              return ExpansionTile(
                title: Text(
                  branch,
                  style: const TextStyle(fontFamily: 'Nexa'),
                ),
                children: semesterGroups.entries.map((semesterEntry) {
                  final semester = semesterEntry.key;
                  final studentsInSemester = semesterEntry.value;

                  return ExpansionTile(
                    title: Text(
                      'Semester $semester',
                      style: const TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
                    ),
                    children: studentsInSemester.map((student) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            student['name'] != null ? student['name'][0].toUpperCase() : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          student['name'] ?? 'Name',
                          style: const TextStyle(fontSize: 15, fontFamily: "Nexa"),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student['id'] ?? 'USN',
                              style: const TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
                            ),
                            Text(
                              student['email'] ?? 'Email',
                              style: const TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
                            ),
                            Text(student['phone_no'] ?? 'Phoen Number',
                              style: const TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
                            )
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
