import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class RepScreen extends StatefulWidget {
  const RepScreen({super.key});

  @override
  State<RepScreen> createState() => _RepScreenState();
}

class _RepScreenState extends State<RepScreen> {
  // Lists to store results for each exam
  List<List<String>> cie1Results = [];
  List<List<String>> cie2Results = [];
  List<List<String>> assignmentResults = [];

  // Function to fetch data and generate the PDF
  Future<void> fetchResultsAndGeneratePdf() async {
    try {
      // Fetch data from Firestore
      List<String> exams = ['cie1', 'cie2', 'assignment'];
      Map<String, List<List<String>>> results = {
        'cie1': cie1Results,
        'cie2': cie2Results,
        'assignment': assignmentResults,
      };

      final firestore = FirebaseFirestore.instance;
      final semesterRef = firestore.collection('marks').doc('5');
      final webDevCollection = semesterRef.collection('Web Development');

      for (String exam in exams) {
        final examSnapshot = await webDevCollection.doc(exam).get();

        if (examSnapshot.exists) {
          Map<String, dynamic>? data = examSnapshot.data();

          data?.forEach((studentId, studentData) {
            if (studentData is Map<String, dynamic>) {
              results[exam]!.add([
                studentId,
                studentData['totalMarks']?.toString() ?? '0',
              ]);
            }
          });
        }
      }

      print('CIE1 Results: $cie1Results');
      print('CIE2 Results: $cie2Results');
      print('Assignment Results: $assignmentResults');

      // Generate the PDF
      final pdf = pw.Document();

      // Create a combined map of all students and their marks
      Map<String, Map<String, String>> studentMarks = {};

      // Populate CIE1 results
      for (var entry in cie1Results) {
        studentMarks[entry[0]] ??= {};
        studentMarks[entry[0]]!['cie1'] = entry[1];
      }

      // Populate CIE2 results
      for (var entry in cie2Results) {
        studentMarks[entry[0]] ??= {};
        studentMarks[entry[0]]!['cie2'] = entry[1];
      }

      // Populate Assignment results
      for (var entry in assignmentResults) {
        studentMarks[entry[0]] ??= {};
        studentMarks[entry[0]]!['assignment'] = entry[1];
      }

      // Fill missing marks with 0
      studentMarks.forEach((studentId, marks) {
        marks['cie1'] ??= '0';
        marks['cie2'] ??= '0';
        marks['assignment'] ??= '0';
      });

      // Calculate total for each student
      studentMarks.forEach((studentId, marks) {
        final cie1 = double.parse(marks['cie1']!);
        final cie2 = double.parse(marks['cie2']!);
        final assignment = double.parse(marks['assignment']!);
        marks['total'] = (cie1 + cie2 + assignment).toStringAsFixed(1);
      });

      // Create the PDF table
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            children: [
              pw.Text(
                'Student Marks Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Student ID', 'CIE1', 'CIE2', 'Assignment', 'Total'],
                data: studentMarks.entries.map((entry) {
                  final studentId = entry.key;
                  final marks = entry.value;
                  return [
                    studentId,
                    marks['cie1'],
                    marks['cie2'],
                    marks['assignment'],
                    marks['total'],
                  ];
                }).toList(),
              ),
            ],
          ),
        ),
      );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate PDF'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await fetchResultsAndGeneratePdf();
          },
          child: const Text('Generate PDF'),
        ),
      ),
    );
  }
}
