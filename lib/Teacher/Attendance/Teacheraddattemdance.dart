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

  bool _loading = false;
  String _feedbackMessage = '';

  Map<String, String> attendance = {};

  @override
  void initState() {
    super.initState();
  }

  double calculateAttendancePercentage(List<String> history) {
    if (history.isEmpty) {
      return 0.0;
    }
    int presentCount = history.where((status) => status == 'P').length;
    return (presentCount / history.length) * 100;
  }

  Future<void> saveAttendance() async {
    setState(() {
      _loading = true;
      _feedbackMessage = '';
    });

    try {
      for (var studentId in attendance.keys) {
        String status = attendance[studentId] ?? 'A';

        DocumentSnapshot studentDoc = await _studentsRef.doc(studentId).get();

        if (studentDoc.exists) {
          Map<String, dynamic> studentData = studentDoc.data() as Map<String, dynamic>;

          List<String> attendanceHistory = [];
          if (studentData.containsKey('attendance_history')) {
            attendanceHistory = List<String>.from(studentData['attendance_history']);
          }

          attendanceHistory.add(status);

          double attendancePercentage = calculateAttendancePercentage(attendanceHistory);

          await _attendanceRef
              .doc(widget.semester)
              .collection('students')
              .doc(studentId)
              .set({
            'status': status,
            'date': FieldValue.serverTimestamp(),
            'attendance_percentage': attendancePercentage,
          });

          await _studentsRef.doc(studentId).update({
            'attendance_history': attendanceHistory,
          });
        } else {
          await _studentsRef.doc(studentId).set({
            'attendance_history': [status],
            'semester': widget.semester,
          });

          await _attendanceRef
              .doc(widget.semester)
              .collection('students')
              .doc(studentId)
              .set({
            'id': studentId,
            'status': status,
            'date': FieldValue.serverTimestamp(),
            'attendance_percentage': status == 'P' ? 100.0 : 0.0,
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
            icon: Icon(Icons.arrow_back_ios, color: Colors.white)),
        title: Text('${widget.semester} Semester Attendance', style: TextStyle(fontFamily: 'Nexa', color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                final studentDocs = snapshot.data!.docs;

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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: attendance[studentId] == 'P',
                                onChanged: (bool? value) {
                                  setState(() {
                                    attendance[studentId] = value! ? 'P' : 'A';
                                  });
                                },
                              ),
                              Text('P'),
                              SizedBox(width: 10),
                              Checkbox(
                                value: attendance[studentId] == 'A',
                                onChanged: (bool? value) {
                                  setState(() {
                                    attendance[studentId] = value! ? 'A' : 'P';
                                  });
                                },
                              ),
                              Text('A'),
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
                  side: BorderSide(color: Colors.blueAccent)),
              onPressed: saveAttendance,
              child: const Text('Submit Attendance', style: TextStyle(fontSize: 18, fontFamily: 'NexaBold', fontWeight: FontWeight.w900)),
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
