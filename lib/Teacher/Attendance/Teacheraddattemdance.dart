import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  final String semester;
  const AttendancePage({super.key, required this.semester});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _studentsRef = FirebaseFirestore.instance.collection('Admin_Students_List');
  final CollectionReference _attendanceRef = FirebaseFirestore.instance.collection('Attendance');

  // Loading state
  bool _loading = false;

  // Feedback message
  String _feedbackMessage = '';


  Map<String, String> attendance = {}; // Key: student ID, Value: 'P' for Present or 'A' for Absent

  @override
  void initState() {
    super.initState();
  }

  // Calculate attendance percentage based on attendance history
  double calculateAttendancePercentage(List<String> history) {
    if (history.isEmpty) {
      return 0.0;
    }
    int presentCount = history.where((status) => status == 'P').length;
    return (presentCount / history.length) * 100;
  }

  // Save attendance data to Firestore
  Future<void> saveAttendance() async {
    setState(() {
      _loading = true;
      _feedbackMessage = ''; // Clear any previous feedback
    });

    try {
      // Loop through all students and save their attendance status
      for (var studentId in attendance.keys) {
        String status = attendance[studentId] ?? 'A'; // Default to 'A' if no status selected

        // Fetch the current student's document from Admin_Students_List
        DocumentSnapshot studentDoc = await _studentsRef.doc(studentId).get();

        if (studentDoc.exists) {
          // Safely access the student's data as a map
          Map<String, dynamic> studentData = studentDoc.data() as Map<String, dynamic>;

          // Get the current attendance history (if exists), otherwise initialize an empty list
          List<String> attendanceHistory = [];
          if (studentData.containsKey('attendance_history')) {
            attendanceHistory = List<String>.from(studentData['attendance_history']);
          }

          // Add the new attendance status to the history
          attendanceHistory.add(status);

          // Calculate the new attendance percentage
          double attendancePercentage = calculateAttendancePercentage(attendanceHistory);

          // Save the attendance status to the Firestore collection for the corresponding semester (in Attendance)
          await _attendanceRef
              .doc(widget.semester)
              .collection('students')
              .doc(studentId)
              .set({
            'status': status,
            'date': FieldValue.serverTimestamp(), // Add timestamp for the record
            'attendance_percentage': attendancePercentage, // Store attendance percentage here
          });

          // Update the student's attendance history in the Admin_Students_List collection
          await _studentsRef.doc(studentId).update({
            'attendance_history': attendanceHistory,
          });
        } else {
          // If the student document does not exist, initialize it with default values
          await _studentsRef.doc(studentId).set({
            'attendance_history': [status], // Initialize with the first attendance record
            'semester': widget.semester, // Optional, depending on your schema
          });

          // Store initial attendance status and percentage in Attendance collection
          await _attendanceRef
              .doc(widget.semester)
              .collection('students')
              .doc(studentId)
              .set({
            'id':studentId,
            'status': status,
            'date': FieldValue.serverTimestamp(), // Add timestamp for the record
            'attendance_percentage': status == 'P' ? 100.0 : 0.0, // Initial percentage
          });
        }
      }

      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Attendance submitted successfully!')));
      });
    } catch (e) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit attendance: $e')));
      });
    } finally {
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
            icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        title: Text('${widget.semester} Semester Attendance',style: TextStyle(fontFamily: 'Nexa', color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Fetch students from Firestore based on the semester
              stream: _studentsRef
                  .where('semester', isEqualTo: widget.semester)
                  .snapshots(),
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

                // Extract student data from the snapshot
                final studentDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: studentDocs.length,
                  itemBuilder: (context, index) {
                    final student = studentDocs[index];
                    final studentId = student['id'] ?? '';
                    final studentEmail = student['email'] ?? '';
                    //final studentName = student['name'] ?? 'No Name';  // Name of the student

                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.perm_identity),
                          ),
                          title: Text(studentId),
                          subtitle: Text(studentEmail),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Present checkbox
                              Checkbox(
                                value: attendance[studentId] == 'P',
                                onChanged: (bool? value) {
                                  setState(() {
                                    attendance[studentId] = value! ? 'P' : 'A';
                                  });
                                },
                              ),
                              Text('P'), // Present
                              SizedBox(width: 10),
                              // Absent checkbox
                              Checkbox(
                                value: attendance[studentId] == 'A',
                                onChanged: (bool? value) {
                                  setState(() {
                                    attendance[studentId] = value! ? 'A' : 'P';
                                  });
                                },
                              ),
                              Text('A'), // Absent
                            ],
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
              style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.blueAccent)
              ),
              onPressed: saveAttendance,
              child: const Text('Submit Attendance',style: TextStyle(fontSize: 18,fontFamily: 'NexaBold',fontWeight: FontWeight.w900)),
            ),
          ),
          if (_feedbackMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _feedbackMessage,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}