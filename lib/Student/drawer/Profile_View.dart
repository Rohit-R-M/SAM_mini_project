import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ProfileViewScreen extends StatefulWidget {
  @override
  _ProfileViewScreenState createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Uint8List? _image;
  String? _name,
      _id,
      _email,
      _semester,
      _collegeName,
      _branchName,
      _selectedBranch,
      _selectedSem;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController emailidController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController branchController = TextEditingController();
  final TextEditingController phonenoController = TextEditingController();
  final String role = 'Student';

  bool _isLoading = false;

  Future<void> selectImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final Uint8List imageBytes = await pickedImage.readAsBytes();
      setState(() {
        _image = imageBytes; // Set the selected image
      });
    }
  }

  // Function to upload image to Firebase Storage
  Future<String> uploadImage() async {
    if (_image == null) return ''; // No image to upload
    String filePath =
        'profile_images/${_auth.currentUser!.uid}.jpg'; // Path for image
    Reference ref = _storage.ref().child(filePath);
    UploadTask uploadTask = ref.putData(_image!);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl; // Return the URL of the uploaded image
  }

  void updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String? downloadUrl = await uploadImage();

    try {
      User? user = _auth.currentUser; // Ensure _auth is initialized with FirebaseAuth.instance
      if (user != null) {
        // Update Firebase Authentication Profile (displayName and photoURL)
        await user.updateProfile(
          displayName: nameController.text.trim(),
          photoURL: downloadUrl,
        );

        // Query Firestore to get document matching email and usn
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Student_list')
            .where('email', isEqualTo: emailidController.text.trim())
            .where('usn', isEqualTo: idController.text.trim().toUpperCase())
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          await FirebaseFirestore.instance.collection('Student_users').doc(user.uid).set({
            'name': nameController.text.trim(),
            'id': idController.text.trim().toUpperCase(),
            'email':  emailidController.text.trim(),
            'phone_no': phonenoController.text.trim(),
            'semester': _selectedSem,
            'college_name': collegeController.text.trim(),
            'branch_name': _selectedBranch,
            'image_url': downloadUrl, // Store the image URL
          }, SetOptions(merge: true));
          _showDialog("Profile Updated", "Your profile has been successfully updated.");

        } else {
          _showDialog("Failed to Update", 'Please try again');
        }
      }
    } catch (error) {
      _showDialog("Update Failed", "There was an error updating your profile: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  // Function to show dialog messages
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Load initial user data
    final user = _auth.currentUser;
    if (user != null) {
      nameController.text = user.displayName ?? '';
      idController.text = '';
      loadUserDetails(user.uid);
    }
  }

  void loadUserDetails(String uid) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('Student_users').doc(uid).get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;

      setState(() {
        semesterController.text = data['semester'] ?? '';
        idController.text = data['id'] ?? '';
        emailidController.text = data['email'] ?? '';
        phonenoController.text = data['phone_no'] ?? '';
        collegeController.text = data['college_name'] ?? '';
        _selectedSem = data['semester'] ?? '';
        _selectedBranch = data['branch_name'] ?? '';
      });

      if (data['image_url'] != null) {
        http.Response response = await http.get(Uri.parse(data['image_url']));
        setState(() {
          _image = response.bodyBytes;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_sharp),
          color: Colors.white,
        ),
        title: const Text("Edit Profile",
            style: TextStyle(fontFamily: 'Nexa', color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: selectImage,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(70),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 3,
                          blurRadius: 10,
                        )
                      ]),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage:
                        _image != null ? MemoryImage(_image!) : null,
                    child: _image == null
                        ? Icon(Icons.add_a_photo, size: 35)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              buildTextField("Name", nameController),
              buildTextField("ID", idController),
              buildTextField("Email-Id", emailidController),

              buildTextField("Phone No", phonenoController, isPhone: true),
              buildDropdownField("Select the Semester", _selectedSem,
                  ['1', '2', '3', '4', '5', '6', '7', '8']),
              buildTextField("College Name", collegeController),
              buildDropdownField("Select an Branch", _selectedBranch, [
                "Computer Science & Engineering",
                'Information Science & Engineering',
                'Civil Engineering',
                "Mechanical Engineering",
                "Electrical Engineering",
                "Electronics & Communication Engineering",
                "Biotechnology Engineering"
              ]),
              const SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: updateProfile,
                      child: const Text("Save Changes",
                          style: TextStyle(
                              fontFamily: 'NexaBold',
                              fontWeight: FontWeight.w900)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool readOnly = false, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: isPhone ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (isPhone && value.length != 10) {
            return 'Please enter a valid phone number';
          }
          return null;
        },
      ),
    );
  }

  Widget buildDropdownField(
      String label, String? selectedValue, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
          border: OutlineInputBorder(),
        ),
        value: selectedValue,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            if (label.contains('Semester'))
              _selectedSem = newValue;
            else
              _selectedBranch = newValue;
          });
        },
      ),
    );
  }
}
