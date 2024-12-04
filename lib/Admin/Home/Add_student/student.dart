import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {

  final _formkey = GlobalKey<FormState>();
  final studentUqidController = TextEditingController();
  final studentEmailController = TextEditingController();

  final _studentsRef = FirebaseDatabase.instance.ref('Admin_Students_List');
  final _fstudent = FirebaseFirestore.instance.collection('Admin_Students_List');

  final List<String> semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];
  String _selectedSemester = '1';

  bool _addLoading = false;
  bool _rmLoading = false;
  bool _uploadLoading = false;
  String _uploadStatus = "";

  // Add Student
  Future<void> addStudent() async {
    setState(() => _addLoading = true);

    final String uqid = studentUqidController.text.trim().toUpperCase();
    final String email = studentEmailController.text.trim();

    if (uqid.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both Unique ID and Email.')),
      );
      setState(() => _addLoading = false);
      return;
    }

    try {
      final studentSnapshot = await _studentsRef.child(uqid).get();

      if (studentSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student Already exists')),
        );
      } else {
        await _studentsRef.child(uqid).set({
          'role': 'student',
          'id': uqid,
          'email': email,
          'semester': _selectedSemester,
        });

        await _fstudent.doc(uqid).set({
          'role': 'student',
          'id': uqid,
          'email': email,
          'semester': _selectedSemester,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student added successfully!')),
        );
        _clearInputFields();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add the student: $e')),
      );
    } finally {
      setState(() => _addLoading = false);
    }
  }

  // Remove Student
  Future<void> removeStudent() async {
    setState(() => _rmLoading = true);

    final String uqid = studentUqidController.text.trim().toUpperCase();
    if (uqid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Unique ID to remove.')),
      );
      setState(() => _rmLoading = false);
      return;
    }

    try {
      final studentSnapshot = await _studentsRef.child(uqid).get();

      if (studentSnapshot.exists) {
        await _studentsRef.child(uqid).remove();
        await _fstudent.doc(uqid).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student removed successfully!')),
        );

        _clearInputFields();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student with this ID does not exist.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove the student: $e')),
      );
    } finally {
      setState(() => _rmLoading = false);
    }
  }

  Future<void> uploadAndProcessExcelFile() async {
    setState(() {
      _uploadLoading = true;
      _uploadStatus = "";
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        // Upload file to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('uploads/${result.files.single.name}');
        await storageRef.putFile(file);

        // Read Excel file
        final fileBytes = await file.readAsBytes();
        var excel = Excel.decodeBytes(fileBytes);

        for (var sheet in excel.tables.keys) {
          var table = excel.tables[sheet];
          if (table == null) continue;

          for (var row in table.rows) {
            if (row.length >= 2) {
              String? uqid = row[0]?.value?.toString().trim();
              String? email = row[1]?.value?.toString().trim();

              if (uqid != null &&
                  email != null &&
                  uqid.isNotEmpty &&
                  email.isNotEmpty) {

                // Add to Firebase
                await _studentsRef.child(uqid).set({
                  'role': 'student',
                  'id': uqid,
                  'email': email,
                  'semester': _selectedSemester,
                });

                await _fstudent.doc(uqid).set({
                  'role': 'student',
                  'id': uqid,
                  'email': email,
                  'semester': _selectedSemester,
                });
              }
            }
          }
        }

        setState(() => _uploadStatus = "File uploaded successfully!");
      } else {
        setState(() => _uploadStatus = "No file selected.");
      }
    } catch (e) {
      setState(() => _uploadStatus = "Failed to upload: $e");
    } finally {
      setState(() => _uploadLoading = false);
    }
  }

  void _clearInputFields(){
    studentEmailController.clear();
    studentUqidController.clear();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Add Student",
          style:
          TextStyle(fontSize: 25, fontFamily: "Nexa", color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedSemester,
                  items: semesters
                      .map((sem) => DropdownMenuItem(value: sem, child: Text(sem)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedSemester = value!),
                  decoration: const InputDecoration(
                    labelText: "Select Semester",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: studentUqidController,
                  decoration: const InputDecoration(
                    labelText: "Student Unique-Id",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: studentEmailController,
                  decoration: const InputDecoration(
                    labelText: "Student Email-id",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter an email';
                    }
                    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _addLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: addStudent,
                    child: const Text("Add Student"),
                  ),
                  const SizedBox(width: 10),
                  _rmLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: removeStudent,
                    child: const Text("Remove Student"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _uploadLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: uploadAndProcessExcelFile,
                child: const Text("More Students (Upload Excel)"),
              ),
              if (_uploadStatus.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_uploadStatus),
                ),
              Card(
                elevation: 4,
                margin: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 30, left: 20, right: 10,bottom: 30),
                  child: const Text(
                    "Note:\n"
                        "- To add a Student, provide both the Unique ID and Email.\n"
                        "- To remove a Student, only the Unique ID is required.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

