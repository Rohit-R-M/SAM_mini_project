import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {

  final _formkey = GlobalKey<FormState>();
  final teacherUqidController = TextEditingController();
  final teacherEmailController = TextEditingController();

  final _teacherRef = FirebaseDatabase.instance.ref('Admin_Teachers_List');

  bool _addLoading = false;
  bool _rmLoading = false;



  Future<void> addteacher() async {
    setState(() {
      _addLoading = true;
    });

    final String uqid = teacherUqidController.text.trim().toUpperCase();
    final String email = teacherEmailController.text.trim();

    // Validate input
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

      final studentSnapshot = await _teacherRef.child(uqid).get();

      if (studentSnapshot.exists) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Teacher Already exists!')),
        );

        _clearInputFields();
      } else {

        await _teacherRef.child(teacherUqidController.text.toUpperCase()).set({
          'id': uqid,
          'email': email,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Teacher added successfully!')),
        );
        _clearInputFields();
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add the teacher: $e')),
      );
    } finally {
      // Always stop loading state
      setState(() {
        _addLoading = false;
      });
    }
  }

  //Remove Teacher
  Future<void> removeteacher() async {
    final String uqid = teacherUqidController.text.trim().toUpperCase();

    if (uqid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid Unique ID to remove.')),
      );
      return;
    }

    setState(() => _rmLoading = true);

    try {
      final studentSnapshot = await _teacherRef.child(uqid).get();

      if (studentSnapshot.exists) {

        await _teacherRef.child(uqid).remove();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Teacher removed successfully!')),
        );

        _clearInputFields();

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Teacher with this ID does not exist.')),
        );

      }
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Teacher to remove the student: $e')),
      );

    } finally {
      setState(() => _rmLoading = false);
    }
  }

  void _clearInputFields(){
    teacherUqidController.clear();
    teacherEmailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios)),
        title: Text("Add Teacher's"),
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
                controller: teacherUqidController,
                decoration: InputDecoration(
                  label: Text("Teachers Unique-Id"),
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: teacherEmailController,
                decoration: InputDecoration(
                  label: Text("Teachers Email-id"),
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
                  onPressed: addteacher,
                  child: Text("Add Teacher"),
                ),

                SizedBox(
                  width: 20,
                ),

                _rmLoading ? CircularProgressIndicator():
                ElevatedButton(
                  onPressed: removeteacher,
                  child: Text("Remove Teacher"),
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
                  "- To add a Teacher, provide both the Unique ID and Email.\n"
                  "- To remove a Teacher, only the Unique ID is required.",
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
