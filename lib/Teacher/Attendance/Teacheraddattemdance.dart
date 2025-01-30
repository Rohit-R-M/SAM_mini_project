import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
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
  final CollectionReference _studentsRef =
  FirebaseFirestore.instance.collection('Admin_Students_List');
  final CollectionReference _attendanceRef =
  FirebaseFirestore.instance.collection('Attendance');

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
      print("Starting attendance submission...");
      DocumentReference semesterDoc = _attendanceRef.doc(widget.semester);
      CollectionReference courseCollection =
      semesterDoc.collection(widget.courseName);

      for (var studentId in attendance.keys) {
        String status = attendance[studentId] ?? 'A'; // Default to 'A' if not set

        DocumentReference studentDoc = courseCollection.doc(studentId);
        DocumentSnapshot studentSnapshot = await studentDoc.get();
        int present = 0;
        int total = 0;

        if (studentSnapshot.exists) {
          Map<String, dynamic> studentData =
          studentSnapshot.data() as Map<String, dynamic>;
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
        print("Attendance for student $studentId updated successfully.");
      }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance submitted successfully!')));
    } catch (e) {
      print("Error during attendance submission: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit attendance: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Generate a PDF report with attendance data
  Future<void> printAttendanceData() async {
    try {
      print("Generating attendance PDF report...");

      // Fetch attendance data from Firestore
      DocumentReference semesterDoc = _attendanceRef.doc(widget.semester);
      CollectionReference courseCollection =
      semesterDoc.collection(widget.courseName);

      QuerySnapshot studentsSnapshot = await courseCollection.get();

      if (studentsSnapshot.docs.isEmpty) {
        print("No attendance records found.");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No attendance records found.')));
        return;
      }

      // Create the PDF document
      final pdf = pw.Document();
      const int rowsPerPage = 20; // Adjust based on how many rows fit per page
      int pageCount = (studentsSnapshot.docs.length / rowsPerPage).ceil();

      for (int page = 0; page < pageCount; page++) {
        // Add a page to the PDF
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              // Fetch only the required rows for the current page
              int startIndex = page * rowsPerPage;
              int endIndex = startIndex + rowsPerPage;
              var pageDocs = studentsSnapshot.docs
                  .skip(startIndex)
                  .take(rowsPerPage)
                  .toList();

              List<List<String>> pageData = [];

              int counter = startIndex + 1;
              for (var doc in pageDocs) {
                Map<String, dynamic> studentData = doc.data() as Map<String, dynamic>;
                int present = studentData['present'] ?? 0;
                int total = studentData['total'] ?? 0;
                String usn = doc.id;
                String attendancePercentage =
                total > 0 ? (present * 100 / total).toStringAsFixed(2) : '0.00';

                pageData.add([counter.toString(), usn, '$attendancePercentage%']);
                counter++;
              }

              return pw.Column(
                children: [
                  pw.Text(
                    'Attendance Report for ${widget.courseName}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Table.fromTextArray(
                    context: context,
                    data: [
                      ['S.No', 'USN', 'Attendance'],
                      ...pageData,
                    ],
                    border: pw.TableBorder.all(width: 1),
                    cellAlignment: pw.Alignment.center,
                  ),
                  if (page < pageCount - 1) pw.SizedBox(height: 20), // Add space between pages
                  if (page < pageCount - 1)
                    pw.Text('Page ${page + 1} of $pageCount',
                        style: pw.TextStyle(fontSize: 12)),
                ],
              );
            },
          ),
        );
      }

      // Save the PDF to a file
      final outputDir = await getApplicationDocumentsDirectory();
      final file = File('${outputDir.path}/attendance_report.pdf');
      await file.writeAsBytes(await pdf.save());

      // Print the PDF
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance PDF generated successfully!')));
    } catch (e) {
      print("Error during PDF generation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')));
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
        title: Text('${widget.courseName}',
            style: TextStyle(fontFamily: 'Nexa', color: Colors.white)),
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
                  print("Error in student data stream: ${snapshot.error}");
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print("No students found.");
                  return Center(child: Text('No students found.'));
                }

                final studentDocs = snapshot.data!.docs;

                for (var student in studentDocs) {
                  final studentData = student.data() as Map<String, dynamic>;
                  final studentId =
                      studentData['id'] ?? 'Unknown ID'; // Provide fallback
                  attendance[studentId] ??= 'P'; // Set default to 'P'
                }

                return ListView.builder(
                  itemCount: studentDocs.length,
                  itemBuilder: (context, index) {
                    final student = studentDocs[index];
                    final studentData = student.data() as Map<String, dynamic>;
                    final studentId =
                        studentData['id'] ?? 'Unknown ID';
                    final studentEmail =
                        studentData['email'] ?? 'No Email';

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
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(color: Colors.blueAccent)),
                  onPressed: saveAttendance,
                  child: _loading
                      ? Container(
                      height: 30,
                      child: CircularProgressIndicator())
                      : Text('Submit Attendance',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'NexaBold',
                          fontWeight: FontWeight.w900)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(color: Colors.blueAccent)),
                  onPressed: printAttendanceData,
                  child: Text('Report',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'NexaBold',
                          fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
