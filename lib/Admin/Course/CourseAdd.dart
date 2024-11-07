import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminCourseAdd extends StatefulWidget {
  const AdminCourseAdd({super.key});

  @override
  State<AdminCourseAdd> createState() => _AdminCourseAddState();
}

class _AdminCourseAddState extends State<AdminCourseAdd> {

  final _formKey = GlobalKey<FormState>();
  String? _selectedValue;

  final CollectionReference _coursedatabase = FirebaseFirestore.instance.collection('Admin_added_Course');

  final TextEditingController _courseName = TextEditingController();
  final TextEditingController _courseInstructor = TextEditingController();


  bool isloading = false;

  Future<void> addcourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isloading = true;
    });

    try {
      final querySnapshot = await _coursedatabase
          .where('course_name', isEqualTo: _courseName.text.trim())
          .where('semester', isEqualTo: _selectedValue)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course already exists for this semester.')),
        );
        return;
      }

      await _coursedatabase.add({
        'semester': _selectedValue,
        'course_name': _courseName.text.trim(),
        'course_instructor': _courseInstructor.text.trim(),
      });

      _courseName.clear();
      _courseInstructor.clear();
      setState(() {
        _selectedValue = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Course Added Successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add course: $e")));
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        backgroundColor: Colors.blueAccent,
        title: Text("Add Course", style: TextStyle(fontWeight: FontWeight.bold,
            fontFamily: 'Nexa',
            color: Colors.white)),
        centerTitle: true,
      ),

      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Sem", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'NexaBold',fontSize: 20),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select an option',
                      labelStyle: TextStyle( fontFamily: 'NexaBold',fontWeight: FontWeight.w900),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: _selectedValue,
                    items: ['I Semester', 'II Semester', 'III Semester', 'IV Semester', 'V Semester', 'VI Semester', 'VII Semester', 'VIII Semester']
                        .map((String option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ))
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedValue = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Please select the Semester' : null,
                  ),

                  SizedBox(height: 15,),

                  Text("Course Name", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'NexaBold',fontSize: 20),),

                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _courseName,
                    decoration: InputDecoration(

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      label: Text("Course", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'NexaBold',))
                    ),
                    validator: (value){
                      if(value==null || value.isEmpty){
                        return'Please enter the Course Name';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 15,),

                  Text("Course Instructor Name", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'NexaBold',fontSize: 20),),

                  TextFormField(
                    controller: _courseInstructor,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        label: Text("Instructor Name", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'NexaBold',))
                    ),
                    validator: (value){
                      if(value==null || value.isEmpty){
                        return'Please enter Instructor Name';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height:30,),

                  SizedBox(
                    width: 200,
                    child:isloading?Center(child: CircularProgressIndicator()):ElevatedButton(
                      onPressed: () {
                        addcourse();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: Text(
                        "Add Course",
                        style: TextStyle(fontSize: 18, color: Colors.white,fontFamily: 'Nexa'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
