import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sam_pro/Student/notification.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController uqidController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController branchController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController motherNameController = TextEditingController();


  final DatabaseReference _profileData = FirebaseDatabase.instance.ref('Student_list');

  bool _isLoading = false;

  void updateData() async {

    if (!_formKey.currentState!.validate()) return;

    String uqid = uqidController.text.trim();


    setState(() {
      _isLoading = true;
    });

    if (uqid.isNotEmpty) {
      try {
        final DataSnapshot snapshot = await _profileData.get();
        bool isMatch = false;

        // Check if the student ID exists
        for (var student in snapshot.children) {
          final studentData = student.value as Map<Object?, Object?>?;
          if (studentData != null) {
            final Map<String, dynamic> typedData = studentData.map(
                  (key, value) => MapEntry(key as String, value as dynamic),
            );

            final storedId = typedData['usn'] as String?;
            if (storedId != null && storedId == uqid) {
              isMatch = true;
              break;
            }
          }
        }

        if (isMatch) {
          // Update the data if ID matches
          await _profileData.child(uqid).update({
            'name': nameController.text.trim(),
            'class': classController.text.trim(),
            'college': collegeController.text.trim(),
            'branch': branchController.text.trim(),
            'father_name': fatherNameController.text.trim(),
            'mother_name': motherNameController.text.trim(),
          });

          _showDialog("Profile Updated", "Your profile has been successfully updated.");
        } else {
          _showDialog("Update Failed", "There was an error updating your profile. Please try again.");
        }
      } catch (error) {

        _showDialog("Update Failed", "There was an error updating your profile. Please try again.");
      }
    } else {
      _showDialog("Invalid Input", "Please enter a valid ID.");
    }

    // Hide loading indicator
    setState(() {
      _isLoading = false;
    });
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => notificationscreen()),
              );
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 2.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey, // Ensure this is set correctly
          child: Column(
            children: [
              CircleAvatar(
                radius: 70,
                child: IconButton(
                  onPressed: () {
                    // Implement profile picture edit functionality here
                  },
                  icon: Icon(Icons.edit),
                ),
              ),
              const SizedBox(height: 20),
              buildTextField("Name", nameController),
              buildTextField("ID", uqidController),
              buildTextField("Class/Sem", classController),
              buildTextField("College Name", collegeController),
              buildTextField("Branch", branchController),
              buildTextField("Father Name", fatherNameController),
              buildTextField("Mother Name", motherNameController),
              const SizedBox(height: 20),

              _isLoading?CircularProgressIndicator():
              ElevatedButton(
                onPressed: updateData,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildTextField(String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
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
