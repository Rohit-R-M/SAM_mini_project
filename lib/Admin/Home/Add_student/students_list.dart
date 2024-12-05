import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class StudentsList extends StatefulWidget {
  const StudentsList({super.key});

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  final DatabaseReference student =
  FirebaseDatabase.instance.ref('Admin_Students_List');
  final List<String> semesters = ["1", "2", "3", "4", "5", "6", "7", "8"];

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
        title: const Text(
          "Student List",
          style: TextStyle(fontSize: 25, fontFamily: "Nexa", color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: semesters.length,
        itemBuilder: (context, index) {
          final semester = semesters[index];
          return ExpansionTile(
            title: Text(
              "Semester $semester",
              style: TextStyle(fontSize: 18,fontFamily: "Nexa"),
            ),
            children: [
              FutureBuilder(
                future: student
                    .orderByChild('semester')
                    .equalTo(semester)
                    .once(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error fetching data"));
                  }

                  if (snapshot.data?.snapshot.value == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "No students found for Semester $semester",
                          style: TextStyle(color: Colors.grey,fontFamily: "NexaBold",fontWeight: FontWeight.w900),
                        ),
                      ),
                    );
                  }

                  Map studentsData =
                  snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<MapEntry> students = studentsData.entries.toList();

                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: students.length,
                    itemBuilder: (context, studentIndex) {
                      final studentInfo = students[studentIndex].value;
                      return ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.perm_identity),
                        ),
                        title: Text(studentInfo['id'].toString(),style: TextStyle(fontFamily: "NexaBold",fontWeight: FontWeight.w900),),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(studentInfo['email'].toString(),style: TextStyle(fontFamily: "NexaBold",fontWeight: FontWeight.w900)),
                            Text(
                              "Semester: ${studentInfo['semester']}",
                              style:
                              TextStyle(color: Colors.grey, fontSize: 14,fontFamily: "NexaBold"),
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.check, color: Colors.green),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
