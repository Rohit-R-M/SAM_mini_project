import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class AdminAddCalendar extends StatefulWidget {
  const AdminAddCalendar({super.key});

  @override
  State<AdminAddCalendar> createState() => _AdminAddCalendarState();
}

class _AdminAddCalendarState extends State<AdminAddCalendar> {
  File? _image;
  String? _imageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchImageUrl();
  }

  // Function to fetch the image URL from Firestore if it exists
  Future<void> _fetchImageUrl() async {
    final docSnapshot = await FirebaseFirestore.instance.collection('calendar').doc('latest').get();
    if (docSnapshot.exists) {
      setState(() {
        _imageUrl = docSnapshot['imageUrl'];
      });
    }
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  // Function to upload the image to Firebase Storage and Firestore
  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Create a unique filename based on the current timestamp
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('calendar/$fileName');
      final uploadTask = await storageRef.putFile(_image!);

      // Get the image URL from Firebase Storage
      final imageUrl = await uploadTask.ref.getDownloadURL();

      // Store the image URL in Firestore
      await FirebaseFirestore.instance.collection('calendar').doc('latest').set({
        'imageUrl': imageUrl,
        'uploadedAt': Timestamp.now(),
      });

      // Update the UI with the new image URL
      setState(() {
        _imageUrl = imageUrl;
        _image = null; // Clear the local image file after upload
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image updated successfully!")),
      );
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update image")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Colors.blueAccent,
        leading:IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        title: Text("Calendar",style: TextStyle(fontFamily: 'Nexa',color: Colors.white,),),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Display Image if available
          _imageUrl == null && _image == null
              ? Expanded(
            child: Center(
              child: Text("Opening"),
            ),
          )
              : Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PhotoView(
                    imageProvider: _image != null ? FileImage(_image!) : NetworkImage(_imageUrl!) as ImageProvider,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered,
                    backgroundDecoration: BoxDecoration(
                      color: Colors.grey[300]
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20), // Space between image and buttons

          // Uploading Indicator
          if (_isUploading) CircularProgressIndicator(),

          // Single Update Calendar Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                await _pickImage();
              },
              child: Text("Update Calendar"),
            ),
          ),
        ],
      ),
    );
  }
}
