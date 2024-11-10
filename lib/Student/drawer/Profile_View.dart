import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
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

  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController emailidController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController branchController = TextEditingController();
  final TextEditingController phonenoController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  // Function to select image from gallery
  Future<void> selectImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
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
    String filePath = 'profile_images/${_auth.currentUser!.uid}.jpg'; // Path for image
    Reference ref = _storage.ref().child(filePath);
    UploadTask uploadTask = ref.putData(_image!);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl; // Return the URL of the uploaded image
  }

  // Function to update user profile
  void updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String? downloadUrl = await uploadImage();

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Update display name and photo URL in Firebase Auth
        await user.updateProfile(displayName: nameController.text.trim(), photoURL: downloadUrl);

        // Update additional user details in Firestore
        await _firestore.collection('Student_users').doc(user.uid).set({
          'name': nameController.text.trim(),
          'id': idController.text.trim(),
          'email': emailidController.text.trim(),
          'phone_no': phonenoController.text.trim(),
          'semester': semesterController.text.trim(),
          'college_name': collegeController.text.trim(),
          'branch_name': branchController.text.trim(),
          'image_url': downloadUrl, // Store the image URL
        }, SetOptions(merge: true));

        _showDialog("Profile Updated", "Your profile has been successfully updated.");
      }
    } catch (error) {
      _showDialog("Update Failed", "There was an error updating your profile: $error");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
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
    DocumentSnapshot snapshot = await _firestore.collection('Student_users').doc(uid).get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;

      setState(() {
        semesterController.text = data['semester'] ?? '';
        idController.text = data['id'] ?? '';
        emailidController.text = data['email'] ?? '';
        phonenoController.text = data['phone_no'] ?? '';
        collegeController.text = data['college_name'] ?? '';
        branchController.text = data['branch_name'] ?? '';
      });

      if (data['image_url'] != null) {
        // Load image from URL and convert it to Uint8List
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
        title: const Text("Edit Profile", style: TextStyle(fontFamily: 'Nexa', color: Colors.white)),
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
                      ]
                  ),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: _image != null ? MemoryImage(_image!) : null,
                    child: _image == null
                        ? Icon(Icons.add_a_photo, size: 35)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              buildTextField("Name", nameController),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  controller: idController,
                  readOnly: true, // Set to true to make it non-editable
                  decoration: InputDecoration(
                    labelText: "ID",
                    labelStyle: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
                    border: OutlineInputBorder(),
                  ),
                  onTap: () {
                    _showDialog("Field Not Editable", "The ID is set by your admin and cannot be edited.");
                  },
                ),
              ),
              buildTextField("Email ID", emailidController),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  controller: phonenoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Phone No',
                    labelStyle: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Phone Number';
                    } else if (value.length != 10) {
                      return 'Please enter Valid Phone Number';
                    }
                    return null;
                  },
                ),
              ),

              buildTextField("Class", semesterController),
              buildTextField("College Name", collegeController),
              buildTextField("Branch Name", branchController),
              const SizedBox(height: 20),
              _isLoading // Conditional rendering based on loading state
                  ? CircularProgressIndicator() // Show loading indicator
                  : ElevatedButton(
                onPressed: updateProfile,
                child: const Text("Save Changes", style: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget to build text fields with read-only option
Widget buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: TextFormField(
      controller: controller,
      readOnly: readOnly, // Set readOnly property based on the parameter
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    ),
  );
}
