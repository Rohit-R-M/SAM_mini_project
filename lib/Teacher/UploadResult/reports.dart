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

  Future<void> generatePdf(BuildContext context) async {
    try {
      // Convert selected exam to lowercase for comparison
      String examToFetch = selectedExam?.toLowerCase() ?? '';
      final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Fetch data from Firestore based on selected semester and course
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('marks')
          .doc(widget.semester)
          .collection(widget.courseName)
          .doc(examToFetch)
          .get(); // Use .get() to retrieve the document

      if (!snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No data found for the selected exam")),
        );
        return; // Exit if no data found
      }

      // Fetch student data for the selected exam
      Map<String, dynamic>? studentData = snapshot.data() as Map<String, dynamic>?;

      if (studentData == null || studentData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No student data available for the selected exam")),
        );
        return;
      }

      // Prepare the table data for the PDF
      List<List<String>> tableData = [
        ['Student ID', 'Marks'], // Table header
      ];

      studentData.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          // Extract totalMarks from the map
          String totalMarks = value['totalMarks']?.toString() ?? 'No marks'; // Use null-aware access
          tableData.add([key, totalMarks]); // Add studentId (key) and totalMarks to tableData
        }
      });

      // Create the PDF document
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
                  data: tableData.sublist(1), // Exclude headers
                  cellAlignment: pw.Alignment.center, // Align cells to the center
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                  cellStyle: pw.TextStyle(fontSize: 12),
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColors.grey300, // Light background for headers
                  ),
                  border: pw.TableBorder.all(
                    color: PdfColors.black,
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2), // Adjust width of the first column
                    1: pw.FlexColumnWidth(1), // Adjust width of the second column
                  },
                ),
              ],
            );
          },
        ),
      );
      // Save the PDF to local storage
      final directory = await getExternalStorageDirectory(); // For Android
      final filePath = "${directory!.path}/${widget.courseName}_${widget.semester}_${selectedExam}.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Report Generating")),
      );

      // Optionally, open the PDF
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
        backgroundColor: Colors.blueAccent,
        title: Text('Select Exam', style: TextStyle(fontFamily: 'Nexa', color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Box with Border
            Container(
              padding: EdgeInsets.all(16),
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
                    scrollDirection: Axis.horizontal, // Allow horizontal scroll
                    child: Row(
                      children: [
                        _buildOptionButton('CIE1'),
                        SizedBox(width: 16), // Add space between buttons
                        _buildOptionButton('CIE2'),
                        SizedBox(width: 16), // Add space between buttons
                        _buildOptionButton('Assignment'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            // Generate Button
            ElevatedButton(
              onPressed: selectedExam == null
                  ? null
                  : () {
                generatePdf(context); // Generate the PDF
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedExam == null ? Colors.grey : Colors.green,
                foregroundColor: selectedExam == null ? Colors.black54 : Colors.white,
                elevation: selectedExam == null ? 0 : 5,
                side: BorderSide(color: Colors.grey, width: 1),
              ),
              child: Text(
                'Generate PDF',
                style: TextStyle(fontSize: 18, fontFamily: 'NexaBold'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String examName) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedExam = examName; // Update the selected option
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedExam == examName ? Colors.blueAccent : Colors.grey[300],
        foregroundColor: selectedExam == examName ? Colors.white : Colors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        examName,
        style: TextStyle(fontSize: 16, fontFamily: 'Nexa', fontWeight: FontWeight.bold),
      ),
    );
  }
}
