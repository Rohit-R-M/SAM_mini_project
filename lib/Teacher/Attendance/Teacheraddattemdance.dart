import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
      DocumentReference semesterDoc = _attendanceRef.doc(widget.semester);
      CollectionReference courseCollection = semesterDoc.collection(widget.courseName);

      for (var studentId in attendance.keys) {
        String status = attendance[studentId] ?? 'A'; // Default to 'A' if not set

        DocumentReference studentDoc = courseCollection.doc(studentId);
        DocumentSnapshot studentSnapshot = await studentDoc.get();
        int present = 0;
        int total = 0;

        if (studentSnapshot.exists) {
          Map<String, dynamic> studentData = studentSnapshot.data() as Map<String, dynamic>;
          present = studentData['present'] ?? 0;
          total = studentData['total'] ?? 0;
        }

        if (status == 'P') {
          present++;
        }
        total++;

        await studentDoc.set({
          'present': present,
          'total': total,
          'last_status': status,
          'date': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
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

  // Generate PDF report
  Future<void> generatePdfReport() async {
    final pdf = pw.Document();

    try {
      DocumentReference semesterDoc = _attendanceRef.doc(widget.semester);
      CollectionReference courseCollection = semesterDoc.collection(widget.courseName);

      QuerySnapshot studentsSnapshot = await courseCollection.get();

      if (studentsSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No attendance records found.')));
        return;
      }

      List<List<String>> tableData = [];
      int serialNumber = 1;

      for (var doc in studentsSnapshot.docs) {
        Map<String, dynamic> studentData = doc.data() as Map<String, dynamic>;
        int present = studentData['present'] ?? 0;
        int total = studentData['total'] ?? 0;
        String usn = doc.id;
        String attendancePercentage = total > 0 ? (present * 100 / total).toStringAsFixed(2) : '0.00';

        tableData.add([
          serialNumber.toString(),
          usn,
          '$attendancePercentage%'
        ]);
        serialNumber++;
      }

      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            children: [
              pw.Text(
                'Attendance Report - ${widget.courseName}',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['SL No.', 'USN', 'Attendance'],
                data: tableData,
              ),
            ],
          ),
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/Attendance_Report_${widget.courseName}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Printing.sharePdf(bytes: await pdf.save(), filename: 'Attendance_Report_${widget.courseName}.pdf');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
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
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(side: BorderSide(color: Colors.blueAccent)),
                  onPressed: saveAttendance,
                  child: _loading
                      ? Container(height: 30, child: CircularProgressIndicator())
                      : Text('Submit Attendance', style: TextStyle(fontSize: 18, fontFamily: 'NexaBold', fontWeight: FontWeight.w900)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(side: BorderSide(color: Colors.blueAccent)),
                  onPressed: generatePdfReport,
                  child: Text('Report', style: TextStyle(fontSize: 18, fontFamily: 'NexaBold', fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}