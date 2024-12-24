import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class PostAssignmentPage extends StatefulWidget {
  final String semester;
  const PostAssignmentPage({super.key, required this.semester});

  @override
  State<PostAssignmentPage> createState() => _PostAssignmentPageState();
}

class _PostAssignmentPageState extends State<PostAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _assignmentsRef =
      FirebaseFirestore.instance.collection('Assignments');

  File? _selectedFile;
  bool _isLoading = false;
  String? _fileUrl;

  String? _selectedSemester;

  final List<String> _semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> uploadFile() async {
    if (_selectedFile == null) return;

    try {
      String fileName = "${DateTime.now().millisecondsSinceEpoch}.pdf";
      Reference ref =
          FirebaseStorage.instance.ref().child('assignments/$fileName');
      await ref.putFile(_selectedFile!);
      _fileUrl = await ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload file: $e")),
      );
    }
  }

  Future<void> postAssignment() async {
    if (!_formKey.currentState!.validate() || _selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select a semester and fill out all fields.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await uploadFile();

      await _assignmentsRef
          .doc(_selectedSemester)
          .collection('assignments')
          .add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'fileUrl': _fileUrl,
        'date': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Assignment posted successfully for $_selectedSemester!")),
      );

      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      _selectedFile = null;
      _selectedSemester = null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post assignment: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> deleteAssignment(String docId) async {
    try {
      await _assignmentsRef
          .doc(_selectedSemester)
          .collection('assignments')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Assignment deleted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete assignment: $e")),
      );
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text("Post Assessment",
            style: TextStyle(fontFamily: 'Nexa', color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedSemester,
                  hint: const Text("Select Semester"),
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  items: _semesters.map((semester) {
                    return DropdownMenuItem<String>(
                      value: semester,
                      child: Text(semester),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSemester = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Please select a semester" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Assignment Title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Please enter a title"
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: "Assignment Description",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Please enter a description"
                      : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: selectFile,
                  child: const Text("Select PDF File"),
                ),
                if (_selectedFile != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "Selected file: ${_selectedFile!.path.split('/').last}"),
                  ),
                const SizedBox(height: 16),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: postAssignment,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            backgroundColor: Colors.blueAccent,
                          ),
                          child: const Text(
                            "Post Assignment",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                // Display posted assignments at the bottom
                StreamBuilder<QuerySnapshot>(
                  stream: _assignmentsRef
                      .doc(_selectedSemester)
                      .collection('assignments')
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    final assignments = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: assignments.length,
                      itemBuilder: (context, index) {
                        var assignment = assignments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 4,
                          child: ListTile(
                            title: Text(assignment['title']),
                            subtitle: Text(assignment['description']),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteAssignment(assignment.id),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
