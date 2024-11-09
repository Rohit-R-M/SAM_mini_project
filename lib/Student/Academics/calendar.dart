
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class calenderscreen extends StatefulWidget {
  const calenderscreen({super.key});

  @override
  State<calenderscreen> createState() => _calenderscreenState();
}

class _calenderscreenState extends State<calenderscreen> {
  String? _imageUrl;

  // Function to fetch the image URL from Firestore
  Future<void> _fetchImage() async {
    try {
      // Get the document from Firestore
      final docSnapshot = await FirebaseFirestore.instance
          .collection('calendar')
          .doc('latest')
          .get();

      if (docSnapshot.exists) {
        setState(() {
          // Set the image URL from Firestore
          _imageUrl = docSnapshot['imageUrl'];
        });
      }
    } catch (e) {
      print("Error fetching image: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchImage(); // Fetch the image when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Calendar",
          style:
              TextStyle(fontSize: 25, fontFamily: "Nexa", color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _imageUrl == null
          ? Center(
              child:
                  CircularProgressIndicator()) // Loading indicator while fetching
          : Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PhotoView(
                    imageProvider: NetworkImage(_imageUrl!),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered,
                  ),
                ),
              ),
            ),
    );
  }
}
