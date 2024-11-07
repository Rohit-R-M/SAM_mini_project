import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'drawer/Profile_View.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _name;
  String? _id;
  String? _email;
  String? _semester;
  String? _collegeName;
  String? _branchName;
  String? _imageUrl;
  String? _phoneno;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot snapshot =
            await _firestore.collection('Student_users').doc(user.uid).get();
        if (snapshot.exists) {
          setState(() {
            final data = snapshot.data() as Map<String, dynamic>;
            _name = data['name'];
            _id = data['id'];
            _email = data['email'];
            _phoneno = data['phone_no'];
            _semester = data['semester'];
            _collegeName = data['college_name'];
            _branchName = data['branch_name'];
            _imageUrl = data['image_url'];
          });
        } else {
          print("User document does not exist.");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    } else {
      print("User is not authenticated.");
    }
  }

  Future<void> _onRefresh() async {
    await loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        title: const Text(
          "Profile Details",
          style: TextStyle(fontFamily: 'Nexa', color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _name == null
                ? Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 6,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 70,
                              backgroundImage: _imageUrl != null
                                  ? NetworkImage(_imageUrl!)
                                  : null,
                              child: _imageUrl == null
                                  ? Icon(Icons.person,
                                      size: 70, color: Colors.white)
                                  : null,
                              backgroundColor: Colors.blueAccent[300],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildProfileDetail("Name", _name),
                      _buildProfileDetail("ID", _id),
                      _buildProfileDetail('Email ID', _email),
                      _buildProfileDetail("Phone No", _phoneno),
                      _buildProfileDetail("Semester", _semester),
                      _buildProfileDetail("College Name", _collegeName),
                      _buildProfileDetail("Branch Name", _branchName),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(String label, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'NexaBold',
              color: Colors.blueAccent,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nexa',
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
