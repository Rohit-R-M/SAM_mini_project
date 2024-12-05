import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadNotes extends StatefulWidget {
  final String courseName;

  const UploadNotes({super.key, required this.courseName});

  @override
  State<UploadNotes> createState() => _UploadNotesState();
}

class _UploadNotesState extends State<UploadNotes> {
  final TextEditingController pdfNameController = TextEditingController();
  String selectedItem = "Syllabus copy";
  File? selectedFile;
  bool isUploading = false;

  final List<String> dropdownItems = [
    "Syllabus copy",
    "Unit 1",
    "Unit 2",
    "Unit 3",
    "Unit 4",
    "Unit 5",
    "Laboratory Syllabus copy",
    "Other Materials",
  ];

  // List to store uploaded files' details
  List<Map<String, dynamic>> uploadedFiles = [];

  @override
  void initState() {
    super.initState();
    _fetchUploadedFiles();
  }

  Future<void> _fetchUploadedFiles() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.courseName)
          .collection(selectedItem)
          .get();

      List<Map<String, dynamic>> files = [];
      for (var doc in snapshot.docs) {
        files.add({
          'chapter_name': doc['chapter_name'],
          'file_url': doc['file_url'],
          'doc_id': doc.id,
        });
      }

      setState(() {
        uploadedFiles = files;
      });
    } catch (e) {
      print("Error fetching files: $e");
    }
  }

  Future<void> _deleteFile(String docId, String fileUrl) async {
    try {
      // Deleting the file from Firebase Storage
      await FirebaseStorage.instance.refFromURL(fileUrl).delete();

      // Deleting the document from Firestore
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.courseName)
          .collection(selectedItem)
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File deleted successfully")),
      );

      // Remove the file from the list
      setState(() {
        uploadedFiles.removeWhere((file) => file['doc_id'] == docId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_sharp, color: Colors.white),
        ),
        title: const Text(
          "Upload Notes",
          style: TextStyle(fontFamily: 'Nexa', color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Syllabus",
                      style: TextStyle(fontSize: 18, fontFamily: "Nexa"),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedItem,
                      isExpanded: true,
                      items: dropdownItems.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: "NexaBold",
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedItem = value!;
                          _fetchUploadedFiles(); // Refresh file list when syllabus changes
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Chapter Name (PDF Name)",
                      style: TextStyle(fontSize: 18, fontFamily: "Nexa"),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: pdfNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Enter PDF Name",
                        labelStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: "NexaBold",
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton.icon(
                        onPressed: _selectFile,
                        icon: const Icon(Icons.attach_file),
                        label: const Text("Select File"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: "NexaBold",
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),
                    if (selectedFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              "Selected File: ${selectedFile!.path.split('/').last}",
                              style: const TextStyle(fontSize: 14, fontFamily: "Nexa"),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isUploading ? null : _uploadNotes,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Upload Notes",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "NexaBold",
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 10),
            SingleChildScrollView(
              child: Column(
                children: uploadedFiles.map((file) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            file['chapter_name'],
                            style: const TextStyle(fontSize: 16, fontFamily: "Nexa"),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFile(file['doc_id'], file['file_url']),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    } else {
      setState(() {
        selectedFile = null;
      });
    }
  }

  Future<void> _uploadNotes() async {
    if (pdfNameController.text.isEmpty || selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select a file")),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      String fileName = selectedFile!.path.split('/').last;
      Reference storageRef = FirebaseStorage.instance.ref().child('notes/${widget.courseName}/$fileName');
      UploadTask uploadTask = storageRef.putFile(selectedFile!);

      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String fileUrl = await snapshot.ref.getDownloadURL();

      // Save file details to Firestore
      await FirebaseFirestore.instance.collection('notes').doc(widget.courseName).collection(selectedItem).add({
        'chapter_name': pdfNameController.text,
        'file_url': fileUrl,
      });

      // Refresh the file list
      _fetchUploadedFiles();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File uploaded successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }
}
