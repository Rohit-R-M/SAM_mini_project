import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UploadMarks extends StatefulWidget {
  final String studentName;
  final String studentID;
  final String semester;
  final String courseName;

  const UploadMarks({
    super.key,
    required this.studentName,
    required this.studentID,
    required String this.semester,
    required String this.courseName,
  });

  @override
  State<UploadMarks> createState() => _UploadMarksState();
}

class _UploadMarksState extends State<UploadMarks> {
  // Separate lists for CIE-1 and CIE-2 questions
  List<Map<String, dynamic>> questionsCIE1 = [
    {'q': 1, 'a': '', 'b': '', 'c': '', 'd': '', 'total': ''},
    {'q': 2, 'a': '', 'b': '', 'c': '', 'd': '', 'total': ''},
    {'q': 3, 'a': '', 'b': '', 'c': '', 'd': '', 'total': ''},
  ];

  List<Map<String, dynamic>> questionsCIE2 = [
    {'q': 1, 'a': '', 'b': '', 'c': '', 'd': '', 'total': ''},
    {'q': 2, 'a': '', 'b': '', 'c': '', 'd': '', 'total': ''},
    {'q': 3, 'a': '', 'b': '', 'c': '', 'd': '', 'total': ''},
  ];

  // Function to get total marks
  double getTotalMarks(List<Map<String, dynamic>> questions) {
    double totalMarks = 0;
    for (var question in questions) {
      if (question['total'] != null && question['total'].isNotEmpty) {
        totalMarks += double.tryParse(question['total']) ?? 0;
      }
    }
    return totalMarks;
  }

  double assignmentMarks = 0;
  double quizMarks = 0;
  double getTotalMarksAssignment() {
    double totalMarks=0;
    totalMarks=assignmentMarks + quizMarks;
    return totalMarks;
  }
  // Function to save marks to Firestore under structured path for CIE-1
  void saveMarksToFirestoreCIE1() async {
    try {
      String studentID = widget.studentID;
      double totalMarks = getTotalMarks(questionsCIE1);

      // Prepare data to store in Firestore
      Map<String, dynamic> marksData = {
        'studentID': studentID,
        'totalMarks': totalMarks,
      };

      // Store marks data in Firestore
      await FirebaseFirestore.instance
          .collection('marks')
          .doc(widget.semester)
          .collection(widget.courseName)
          .doc('cie1')
          .set({
        studentID: marksData,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CIE-1 Marks Uploaded successfully")),
      );
    } catch (e) {
      print('Error saving marks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error Uploading CIE-1 marks")),
      );
    }
  }

  // Function to save marks to Firestore under structured path for CIE-2
  void saveMarksToFirestoreCIE2() async {
    try {
      String studentID = widget.studentID;
      double totalMarks = getTotalMarks(questionsCIE2);

      // Prepare data to store in Firestore
      Map<String, dynamic> marksData = {
        'studentID': studentID,
        'totalMarks': totalMarks,
      };

      // Store marks data in Firestore
      await FirebaseFirestore.instance
          .collection('marks')
          .doc(widget.semester)
          .collection(widget.courseName)
          .doc('cie2')
          .set({
        studentID: marksData,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CIE-2 Marks Uploaded successfully")),
      );
    } catch (e) {
      print('Error saving marks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error Uploading CIE-2 marks")),
      );
    }
  }


  void saveMarksToFirestoreAssignment() async {
    try{
      String studentID = widget.studentID;
      double totalMarks = getTotalMarksAssignment();

      // Prepare the data to store in Firestore
      Map<String, dynamic> marksData = {
        'studentID': studentID,
        'totalMarks': totalMarks,  // Store only total marks
      };
      // Store data under 'marks' -> 'assignment' -> studentID
      await FirebaseFirestore.instance
          .collection('marks')
          .doc(widget.semester)
          .collection(widget.courseName)
          .doc('assignment')
          .set({
        studentID: marksData,
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Marks Uploaded successfully")));
    } catch (e) {
      // Optionally, handle errors
      print('Error saving marks: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error uploading marks")));
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        title: Text(
          "Upload Marks",
          style: TextStyle(fontFamily: 'Nexa', color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${widget.studentName}',
              style: TextStyle(fontSize: 18, fontFamily: 'Nexa'),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                buildExpansionTile(
                  title: "CIE-1",
                  questions: questionsCIE1,
                  saveFunction: saveMarksToFirestoreCIE1,
                ),
                buildExpansionTile(
                  title: "CIE-2",
                  questions: questionsCIE2,
                  saveFunction: saveMarksToFirestoreCIE2,
                ),
                ExpansionTile(
                    title:ListTile(
                      leading: Icon(Icons.book),
                      title: Text("Assignment", style: TextStyle(
                        fontFamily: 'NexaBold',
                        fontWeight: FontWeight.w900,
                      ),),
                    ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Marks Input',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,fontFamily: 'NexaBold'),
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
                              labelStyle: TextStyle(fontFamily: "NexaBold",fontWeight: FontWeight.w900),
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
                              labelStyle: TextStyle(fontFamily: "NexaBold",fontWeight: FontWeight.w900),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 5),
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
                                      fontFamily: 'Nexa',
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total Marks: ${getTotalMarksAssignment().toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Nexa',
                                        ),
                                      ),
                                     ElevatedButton(
                                          onPressed: () {
                                            saveMarksToFirestoreAssignment();  // Call save data function
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50),
                                              side: BorderSide(color: Colors.blueAccent,width: 1),
                                            ),
                                          ),
                                          child: Text(
                                            "Upload",
                                            style: TextStyle(fontFamily: "NexaBold",fontWeight: FontWeight.w900),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget to create ExpansionTile for CIE sections
  Widget buildExpansionTile({
    required String title,
    required List<Map<String, dynamic>> questions,
    required VoidCallback saveFunction,
  }) {
    return ExpansionTile(
      title: ListTile(
        leading: Icon(Icons.book),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'NexaBold',
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marks distribution',
                  style: TextStyle(fontSize: 22,fontFamily: 'NexaBold',fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 20),
                buildMarksTable(questions),
                SizedBox(height: 20),
                Card(
                  elevation: 4,
                  color: Colors.lightBlue.shade50,
                  margin: EdgeInsets.only(top: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Total Marks: ${getTotalMarks(questions)}',
                            style: TextStyle(fontSize: 20,fontFamily: 'Nexa'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: saveFunction,
                          child: Text("Upload",style: TextStyle(fontFamily: 'NexaBold',fontWeight: FontWeight.w900),),
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(color: Colors.blueAccent,width: 1)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget to build the table for entering marks
  Widget buildMarksTable(List<Map<String, dynamic>> questions) {
    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            tableHeader('Q.No'),
            tableHeader('a'),
            tableHeader('b'),
            tableHeader('c'),
            tableHeader('d'),
            tableHeader('Total'),
          ],
        ),
        for (var question in questions)
          TableRow(
            children: [
              tableCell('${question['q']}'),
              buildTextFieldCell(question, 'a'),
              buildTextFieldCell(question, 'b'),
              buildTextFieldCell(question, 'c'),
              buildTextFieldCell(question, 'd'),
              buildTextFieldCell(question, 'total'),
            ],
          ),
      ],
    );
  }

  // Helper widget to create table headers
  Widget tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper widget to create cells with text input fields
  Widget buildTextFieldCell(Map<String, dynamic> question, String field) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: TextField(
          keyboardType: TextInputType.number,
          onChanged: (val) {
            setState(() {
              question[field] = val;
            });
          },
          decoration: InputDecoration(),
        ),
      ),
    );
  }

  // Helper widget to create standard table cells
  Widget tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(text),
    );
  }
}
