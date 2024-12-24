import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentAssignmentsPage extends StatefulWidget {
  @override
  _StudentAssignmentsPageState createState() => _StudentAssignmentsPageState();
}

class _StudentAssignmentsPageState extends State<StudentAssignmentsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _studentSemester;

  @override
  void initState() {
    super.initState();
    _loadStudentSemester();
  }

  Future<void> _loadStudentSemester() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot snapshot =
            await _firestore.collection('Student_users').doc(user.uid).get();
        if (snapshot.exists) {
          setState(() {
            final data = snapshot.data() as Map<String, dynamic>;
            _studentSemester = data['semester'];
          });
        } else {
          print("User document does not exist.");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    } else {
      print("User is not authenticated.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            )),
        title: const Text(
          "Assessments",
          style: TextStyle(color: Colors.white, fontFamily: "Nexa"),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _studentSemester == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Assignments')
                  .doc(_studentSemester) // Filter by student's semester
                  .collection('assignments')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child:
                          Text("No assignments available for your semester."));
                }

                final assignments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];

                    final title = assignment['title'] ?? 'No Title';
                    final description =
                        assignment['description'] ?? 'No Description';
                    final date = assignment['date'];

                    String dateText = 'No due date';
                    if (date != null && date is Timestamp) {
                      dateText = date.toDate().toString();
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text(description),
                        trailing: Text(
                          'Due: $dateText',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          // Implement any action on tapping an assignment
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
