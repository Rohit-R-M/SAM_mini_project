import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'adminnotice.dart';

class AddNotice extends StatefulWidget {
  const AddNotice({super.key});

  @override
  State<AddNotice> createState() => _AddNoticeState();
}

class _AddNoticeState extends State<AddNotice> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  final _addNoticeCollection = FirebaseFirestore.instance.collection('Posted_Notice');
  String? _fileUrl;
  File? _selectedFile;

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
      Reference ref = FirebaseStorage.instance.ref().child('uploads/$fileName');
      await ref.putFile(_selectedFile!);
      _fileUrl = await ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload file: $e")),
      );
    }
  }

  Future<void> postNotice() async {
    if (!_formKey.currentState!.validate()) return;

    await uploadFile();

    try {
      final noticeId = DateTime.now().millisecondsSinceEpoch.toString();
      await _addNoticeCollection.doc(noticeId).set({
        'title': _titleController.text,
        'desc': _descController.text,
        'fileUrl': _fileUrl,
        'day': Timestamp.fromDate(DateTime.now()),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Notice Posted Sucessful!")));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post notice: $e")),
      );
    }
    _formKey.currentState!.reset(); // Reset form fields
    _titleController.clear();
    _descController.clear();
  }

  Future<void> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Post Notice"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Divider(thickness: 2),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _titleController,
                  maxLength: 50,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Add Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Please enter the title" : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _descController,
                  maxLength: 300,
                  maxLines: 7,
                  decoration: InputDecoration(
                    labelText: "Add Description",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Please enter the description" : null,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: postNotice,
                    child: const Text("Post Notice"),
                  ),
                ],
              ),

              SizedBox(height: 15,),

              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminNoticeScreen()),
                  );
                },
                child: const Text("View Posted Notices"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
