import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {

  final _formkey = GlobalKey<FormState>();
  final studentUqidController = TextEditingController();
  final studentEmailController = TextEditingController();

  final _studentsRef = FirebaseDatabase.instance.ref('Admin_Students_List');


  bool _addLoading = false;
  bool _rmLoading = false;


  //Student ADD
  Future<void> addStudent() async {
    setState(() {
      _addLoading = true;
    });

    final String uqid = studentUqidController.text.trim();
    final String email = studentEmailController.text.trim();

    if (uqid.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both Unique ID and Email.')),
      );
      setState(() {
        _addLoading = false;
      });
      return;
    }

    try {
      final studentSnapshot = await _studentsRef.child(uqid).get();

      if (studentSnapshot.exists) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student Already exists!')),
        );

      } else {
        await _studentsRef.child(studentUqidController.text.toUpperCase()).set({
          'id': uqid.toUpperCase(),
          'email': email,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student added successfully!')),
        );
        _clearInputFields();
      }

    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add the student: $e')),
      );
    } finally {
      setState(() {
        _addLoading = false;
      });
    }
  }

  //Student remove
  Future<void> removeStudent() async {
    final String uqid = studentUqidController.text.trim();

    if (uqid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid Unique ID to remove.')),
      );
      return;
    }

    setState(() => _rmLoading = true);

    try {
      final studentSnapshot = await _studentsRef.child(uqid).get();

      if (studentSnapshot.exists) {

        await _studentsRef.child(uqid).remove();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student removed successfully!')),
        );

        _clearInputFields();

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student with this ID does not exist.')),
        );

      }
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove the student: $e')),
      );

    } finally {
      setState(() => _rmLoading = false);
    }
  }

  void _clearInputFields(){
    studentEmailController.clear();
    studentUqidController.clear();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios)),
        title: Text("Add Student's"),
        centerTitle: true,
      ),

      body:Form(
        key: _formkey,

        child: Column(
          children: [

            Container(
              height: 3,
              color: Colors.grey,
            ),
            SizedBox(height: 5,),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: studentUqidController,
                decoration: InputDecoration(
                  label: Text("Student Unique-Id"),
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: studentEmailController,
                decoration: InputDecoration(
                  label: Text("Student Email-id"),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _addLoading ? CircularProgressIndicator():
                ElevatedButton(
                  onPressed: addStudent,
                  child: Text("Add Student"),
                ),

                SizedBox(
                  width: 20,
                ),

                _rmLoading ? CircularProgressIndicator():
                ElevatedButton(
                  onPressed: removeStudent,
                  child: Text("Remove Student"),
                ),
              ],
            ),
            Card(
              elevation: 4,
              margin: const EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 20, right: 10,bottom: 30),
                child: const Text(
                  "Note:\n"
                      "- To add a Student, provide both the Unique ID and Email.\n"
                      "- To remove a Student, only the Unique ID is required.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

