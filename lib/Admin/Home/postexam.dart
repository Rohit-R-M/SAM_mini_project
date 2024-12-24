import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class PostExamNotice extends StatefulWidget {
  const PostExamNotice({super.key});

  @override
  State<PostExamNotice> createState() => _PostExamNoticeState();
}

class _PostExamNoticeState extends State<PostExamNotice> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  final _examNoticeCollection = FirebaseFirestore.instance.collection('Exam_Notice');
  String? _fileUrl;
  File? _selectedFile;
  bool isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> uploadFile() async {
    if (_selectedFile == null) return;

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.pdf';
      Reference ref = FirebaseStorage.instance.ref().child('exam_notices/$fileName');
      await ref.putFile(_selectedFile!);
      _fileUrl = await ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload file: $e")),
      );
    }
  }

  Future<void> postExamNotice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    await uploadFile();

    try {
      final noticeId = DateTime.now().millisecondsSinceEpoch.toString();
      await _examNoticeCollection.doc(noticeId).set({
        'title': _titleController.text,
        'desc': _descController.text,
        'fileUrl': _fileUrl,
        'day': Timestamp.fromDate(DateTime.now()),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Exam Notice Posted Successfully!")));

      // Reset the form fields after posting
      _formKey.currentState!.reset();
      _titleController.clear();
      _descController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post exam notice: $e")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> deleteExamNotice(String noticeId) async {
    try {
      await _examNoticeCollection.doc(noticeId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Exam Notice Deleted Successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete exam notice: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text("Post Exam Notice", style: TextStyle(fontFamily: 'Nexa', color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Form to post new exam notice
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _titleController,
                        maxLength: 50,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: "Add Exam Title",
                          labelStyle: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Please enter the exam title" : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _descController,
                        maxLines: 7,
                        decoration: InputDecoration(
                          labelText: "Add Exam Description",
                          labelStyle: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Please enter the exam description" : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: selectFile,
                        child: const Text("Select PDF File"),
                      ),
                    ),
                    if (_selectedFile != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Selected file: ${_selectedFile!.path.split('/').last}"),
                      ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: 200,
                      child: isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: postExamNotice,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: Text(
                          "Post Exam Notice",
                          style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Nexa'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Display posted exam notices
            StreamBuilder<QuerySnapshot>(
              stream: _examNoticeCollection.orderBy('day', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No exam notices posted yet.'));
                }

                final notices = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: notices.length,
                  itemBuilder: (context, index) {
                    final notice = notices[index];
                    final noticeId = notice.id;
                    final title = notice['title'];
                    final desc = notice['desc'];
                    final fileUrl = notice['fileUrl'];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(desc),
                            if (fileUrl != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text("File: $fileUrl", style: TextStyle(color: Colors.blue)),
                              ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteExamNotice(noticeId),
                                ),
                              ],
                            ),
                          ],
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
    );
  }
}