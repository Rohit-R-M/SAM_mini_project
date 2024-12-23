import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  final String semester;
  final String id;
  final String name;
  final String courseName;

  const AttendancePage({
    super.key,
    required this.semester,
    required this.courseName,
    required this.id,
    required this.name,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _studentsRef = FirebaseFirestore.instance.collection('Admin_Students_List');
  final CollectionReference _attendanceRef = FirebaseFirestore.instance.collection('Attendance');
  final CollectionReference _courseRef = FirebaseFirestore.instance.collection('Admin_added_Course'); // Course Collection Reference

  bool _loading = false;
  Map<String, String> attendance = {}; // Stores attendance for each student

  @override
  void initState() {
    super.initState();
  }

  // Save attendance data to Firestore
  Future<void> saveAttendance() async {
    setState(() {
      _loading = true;
    });

    try {
      // Get reference to semester document
      DocumentReference semesterDoc = _attendanceRef.doc(widget.semester);

      // Create subcollection for course if not exists
      CollectionReference courseCollection = semesterDoc.collection(widget.courseName);

      for (var studentId in attendance.keys) {
        String status = attendance[studentId] ?? 'A'; // Default to 'A' if not set

        // Get reference for student's attendance document
        DocumentReference studentDoc = courseCollection.doc(studentId);

        // Fetch current data for the student
        DocumentSnapshot studentSnapshot = await studentDoc.get();
        int present = 0;
        int total = 0;

        // If the student document already exists, fetch present and total values
        if (studentSnapshot.exists) {
          Map<String, dynamic> studentData = studentSnapshot.data() as Map<String, dynamic>;
          present = studentData['present'] ?? 0;
          total = studentData['total'] ?? 0;
        }

        // Update attendance counts based on presence
        if (status == 'P') {
          present++;
        }
        total++;

        // Update student attendance document
        await studentDoc.set({
          'present': present,
          'total': total,
          'last_status': status,
          'date': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Display success message
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Attendance submitted successfully!')));
      });
    } catch (e) {
      // Display error message
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit attendance: $e')));
      });
    } finally {
      // Reset loading state
      setState(() {
        _loading = false;
      });
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
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text('${widget.courseName}', style: TextStyle(fontFamily: 'Nexa', color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _studentsRef.where('semester', isEqualTo: widget.semester).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No students found.'));
                }

                final studentDocs = snapshot.data!.docs;

                for (var student in studentDocs) {
                  final studentData = student.data() as Map<String, dynamic>;
                  final studentId = studentData['id'] ?? 'Unknown ID'; // Provide a fallback for null
                  attendance[studentId] ??= 'P'; // Set default to 'P' if not already set
                }

                return ListView.builder(
                  itemCount: studentDocs.length,
                  itemBuilder: (context, index) {
                    final student = studentDocs[index];
                    final studentData = student.data() as Map<String, dynamic>;
                    final studentId = studentData.containsKey('id') ? studentData['id'] : 'Unknown ID';
                    final studentEmail = studentData.containsKey('email') ? studentData['email'] : 'No Email';

                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.perm_identity),
                          ),
                          title: Text(studentId),
                          subtitle: Text(studentEmail),
                          trailing: StatefulBuilder(
                            builder: (context, setLocalState) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('P'),
                                      Radio<String>(
                                        value: 'P',
                                        groupValue: attendance[studentId],
                                        onChanged: (value) {
                                          setLocalState(() {
                                            attendance[studentId] = value!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('A'),
                                      Radio<String>(
                                        value: 'A',
                                        groupValue: attendance[studentId],
                                        onChanged: (value) {
                                          setLocalState(() {
                                            attendance[studentId] = value!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Divider(
                          thickness: 2,
                          indent: 5,
                          endIndent: 5,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(side: BorderSide(color: Colors.blueAccent)),
              onPressed: saveAttendance,
              child: _loading
                  ? Container(height: 30, child: CircularProgressIndicator())
                  : Text('Submit Attendance', style: TextStyle(fontSize: 18, fontFamily: 'NexaBold', fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
