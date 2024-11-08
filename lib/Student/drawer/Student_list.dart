import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentsList extends StatefulWidget {
  const StudentsList({super.key});

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {

  final _studlist = FirebaseFirestore.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        title: const Text(
          "Students List",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500,fontFamily: 'Nexa',color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
          stream: _studlist.collection('Student_users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          final students = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
              itemCount: students.length,
              itemBuilder: (context, index) {
                var student = students[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      student['name'] != null ? student['name'][0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    student['name'] ?? 'Name',
                    style: const TextStyle(fontSize: 20, fontFamily: "Nexa"),
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
                    ],
                  ),
                  trailing: Text(student['semester'] ?? 'Semester',
                    style: const TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900,fontSize: 20),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(
                thickness: 1.0,
                color: Colors.grey,
              ),
            ),
          );

        },),
    );
  }
}
