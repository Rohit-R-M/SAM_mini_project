import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignmentScreen extends StatefulWidget {
  final String title;
  final String studentID;
  const AssignmentScreen({super.key, required this.title, required this.studentID});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  double assignmentMarks = 0;
  double quizMarks = 0;

  // Assuming you will pass the student's ID from the previous screen or use a unique ID.
  String studentId = "student_123";  // Replace this with dynamic student ID if required.

  double getTotalMarks() {
    double totalMarks=0;
    totalMarks=assignmentMarks + quizMarks;
    return totalMarks;
  }

  //function to save only total marks and student ID
  void saveMarksToFirestore() async {
    try{
      String studentID = widget.studentID;
      double totalMarks = getTotalMarks();

      // Prepare the data to store in Firestore
      Map<String, dynamic> marksData = {
        'studentID': studentID,
        'totalMarks': totalMarks,  // Store only total marks
      };
      // Store data under 'marks' -> 'assignment' -> studentID
      await FirebaseFirestore.instance
          .collection('marks')
          .doc('assignment')
          .set({
        studentID: marksData,
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Marks saved successfully")));
    } catch (e) {
      // Optionally, handle errors
      print('Error saving marks: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving marks")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Assignment & Quiz Marks",
            style: TextStyle(fontSize: 24),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marks Input',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() {
                    assignmentMarks = double.tryParse(val) ?? 0;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Assignments (Max 5)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() {
                    quizMarks = double.tryParse(val) ?? 0;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Quiz (Max 5)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                color: Colors.lightBlue.shade50,
                margin: EdgeInsets.only(top: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Maximum Marks: 10.00",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "Total Marks: ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "${getTotalMarks().toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 80),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    saveMarksToFirestore();  // Call save data function
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.white),
                    ),
                  ),
                  child: Text(
                    "Save",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}