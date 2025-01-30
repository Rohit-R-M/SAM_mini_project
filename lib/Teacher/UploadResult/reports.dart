import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Reports extends StatefulWidget {
  final String semester;
  final String courseName;

  const Reports({super.key, required this.semester, required this.courseName});

  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  String? selectedExam; // To track the selected exam

  Future<void> fetchResultsAndGeneratePdf() async {
    try {
      // Fetch data from Firestore
      List<String> exams = ['cie1', 'cie2', 'assignment'];
      Map<String, List<List<String>>> results = {
        'cie1': [],
        'cie2': [],
        'assignment': [],
      };

      final firestore = FirebaseFirestore.instance;
      final semesterRef = firestore.collection('marks').doc(widget.semester);
      final courseCollection = semesterRef.collection(widget.courseName);
      final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (String exam in exams) {
        final examSnapshot = await courseCollection.doc(exam).get();

        if (examSnapshot.exists) {
          Map<String, dynamic>? data = examSnapshot.data();

          data?.forEach((studentId, studentData) {
            if (studentData is Map<String, dynamic>) {
              results[exam]!.add([studentId, studentData['totalMarks']?.toString() ?? '0']);
            }
          });
        }
      }

      // Generate the PDF
      final pdf = pw.Document();

      // Create a combined map of all students and their marks
      Map<String, Map<String, String>> studentMarks = {};

      // Populate results for each exam
      results.forEach((exam, entries) {
        for (var entry in entries) {
          studentMarks[entry[0]] ??= {};
          studentMarks[entry[0]]![exam] = entry[1];
        }
      });

      // Fill missing marks with 0 and calculate totals
      studentMarks.forEach((studentId, marks) {
        marks['cie1'] ??= '0';
        marks['cie2'] ??= '0';
        marks['assignment'] ??= '0';
        final total = double.parse(marks['cie1']!) +
            double.parse(marks['cie2']!) +
            double.parse(marks['assignment']!);
        marks['total'] = total.toStringAsFixed(1);
      });

      // Create the PDF table with serial number
      final List<List<dynamic>> pdfData = studentMarks.entries.map((entry) {
        final studentId = entry.key;
        final marks = entry.value;
        return [
          studentMarks.keys.toList().indexOf(studentId) + 1, // Correct serial number
          studentId,
          marks['cie1'],
          marks['cie2'],
          marks['assignment'],
          marks['total'],
        ];
      }).toList();

      // Pagination logic: Split the data into pages if necessary
      final List<List<List<dynamic>>> paginatedData = _paginateData(pdfData, 25); // 25 rows per page

      // Add pages to the PDF
      for (int pageIndex = 0; pageIndex < paginatedData.length; pageIndex++) {
        pdf.addPage(
          pw.Page(
            build: (context) {
              final pageData = paginatedData[pageIndex];
              return pw.Column(
                children: [
                  pw.Text(
                    '${widget.courseName} - ${selectedExam ?? ''}',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Date: $formattedDate',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Table.fromTextArray(
                    headers: ['SL No.', 'Student ID', 'CIE1', 'CIE2', 'Assignment', 'Total'],
                    data: pageData,
                  ),
                ],
              );
            },
          ),
        );
      }

      // Save and preview the PDF
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/student_marks.pdf');
      await file.writeAsBytes(await pdf.save());

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
      print('PDF Generated at ${file.path}');
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

  List<List<List<dynamic>>> _paginateData(List<List<dynamic>> data, int rowsPerPage) {
    final List<List<List<dynamic>>> pages = [];
    for (int i = 0; i < data.length; i += rowsPerPage) {
      pages.add(data.sublist(i, (i + rowsPerPage) < data.length ? i + rowsPerPage : data.length));
    }
    return pages;
  }

  Future<void> generatePdf(BuildContext context) async {
    try {
      if (selectedExam == 'Final') {
        await fetchResultsAndGeneratePdf(); // Call the new function for Final exam
        return;
      }

      String examToFetch = selectedExam?.toLowerCase() ?? '';
      final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('marks')
          .doc(widget.semester)
          .collection(widget.courseName)
          .doc(examToFetch)
          .get();

      if (!snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No data found for the selected exam")),
        );
        return;
      }

      Map<String, dynamic>? studentData = snapshot.data() as Map<String, dynamic>?;

      if (studentData == null || studentData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No student data available for the selected exam")),
        );
        return;
      }

      List<List<String>> tableData = [
        ['SL No.', 'Student ID', 'Marks'],
      ];

      int slNo = 1;
      studentData.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          String totalMarks = value['totalMarks']?.toString() ?? 'No marks';
          tableData.add([slNo.toString(), key, totalMarks]);
          slNo++;
        }
      });

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${widget.courseName} - ${selectedExam ?? ''}',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Date: $formattedDate',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headers: tableData[0],
                  data: tableData.sublist(1),
                  cellAlignment: pw.Alignment.center,
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                  cellStyle: pw.TextStyle(fontSize: 12),
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  border: pw.TableBorder.all(
                    color: PdfColors.black,
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(1),
                    1: pw.FlexColumnWidth(2),
                    2: pw.FlexColumnWidth(1),
                  },
                ),
              ],
            );
          },
        ),
      );

      final directory = await getExternalStorageDirectory();
      final filePath =
          "${directory!.path}/${widget.courseName}_${widget.semester}_${selectedExam}.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Report Generating")),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating PDF")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(Icons.arrow_back_ios_sharp,color: Colors.white,)),
        backgroundColor: Colors.blueAccent,
        title: Text('Select Exam', style: TextStyle(fontFamily: 'Nexa', color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    "Choose an Exam:",
                    style: TextStyle(fontFamily: 'NexaBold', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildOptionButton('CIE1'),
                        SizedBox(width: 16),
                        _buildOptionButton('CIE2'),
                        SizedBox(width: 16),
                        _buildOptionButton('Final'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: selectedExam == null
                    ? null
                    : () {
                  generatePdf(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedExam == null ? Colors.grey : Colors.green,
                  foregroundColor: selectedExam == null ? Colors.black54 : Colors.white,
                  elevation: selectedExam == null ? 0 : 5,
                  minimumSize: Size(200, 50),
                ),
                child: Text(
                  selectedExam == null
                      ? "Generate PDF"
                      : "Generate PDF",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nexa',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedExam = title;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selectedExam == title ? Colors.blueAccent : Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}