import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddAchievements extends StatefulWidget {
  final String id;
  final String semester;

  const AddAchievements({super.key, required this.id, required this.semester});

  @override
  State<AddAchievements> createState() => _AddAchievementsState();
}

class _AddAchievementsState extends State<AddAchievements> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = "Academic";
  File? _selectedPDF;


  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPDF = File(result.files.single.path!);
      });
    }
  }

  Future<String> _uploadFile(String path, String folderName) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance.ref().child('$folderName/$fileName');
    final uploadTask = storageRef.putFile(File(path));
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  bool isLoading = false;

  Future<void> _saveAchievement() async {

    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      String? pdfUrl;

      try {
        if (_selectedPDF != null) {
          pdfUrl = await _uploadFile(_selectedPDF!.path, 'achievement_pdfs');
        }

        await FirebaseFirestore.instance
            .collection('students_achievements')
            .doc(widget.semester)
            .collection('student Id')
            .doc(widget.id)
            .collection('achievements')
            .add({
          'title': _titleController.text.trim(),
          'category': _selectedCategory,
          'description': _descriptionController.text.trim(),
          'imageUrl': imageUrl,
          'pdfUrl': pdfUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Achievement saved successfully!')),
        );

        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedCategory = "Academic";
          _selectedPDF = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving achievement: $e')),
        );
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: const Text(
          "Achievements",
          style: TextStyle(fontSize: 24, fontFamily: "Nexa", color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Category",
                  style: TextStyle(fontFamily: "Nexa", fontSize: 16,),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: [
                    'Academic',
                    'Sports',
                    'Cultural',
                    'Technical',
                    'Social'
                  ].map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Achievement Title",
                  style: TextStyle(fontFamily: "Nexa", fontSize: 16),
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: "Enter achievement title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  "Description",
                  style: TextStyle(fontFamily: "Nexa", fontSize: 16),
                ),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: "Write a detailed description...",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickPDF,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Files",style: TextStyle(fontFamily: "NexaBold",fontWeight: FontWeight.w900),),
                    ),
                    _selectedPDF != null
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.cancel, color: Colors.red),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveAchievement,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      backgroundColor: Colors.white,
                      elevation: 5,
                    ),
                    child: isLoading?CircularProgressIndicator():Text(
                      "Save Achievement",
                      style: TextStyle(fontSize: 18,fontFamily: "Nexa"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}