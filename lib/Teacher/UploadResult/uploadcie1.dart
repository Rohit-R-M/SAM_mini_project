import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Cie1Screen extends StatefulWidget {
  final String title;
  final String studentID;  // Add studentID as a parameter

  const Cie1Screen({super.key, required this.title, required this.studentID});

  @override
  State<Cie1Screen> createState() => _CieScreenState();
}

class _CieScreenState extends State<Cie1Screen> {
  List<Map<String, dynamic>> questions = [
    {'q': 1, 'a': '', 'b': '', 'c': '', 'd': '', 'total': ''},
    {'q': 2, 'a': '', 'b': '', 'c': '', 'd': '', 'total': ''},
    {'q': 3, 'a': '', 'b': '', 'c': '', 'd': '', 'total': ''},
  ];

  double getTotalMarks() {
    double totalMarks = 0;
    for (var question in questions) {
      if (question['total'] != null && question['total'].isNotEmpty) {
        totalMarks += double.tryParse(question['total']) ?? 0;
      }
    }
    return totalMarks;
  }

  // Function to save only total marks and student ID
  void saveMarksToFirestore() async {
    try {
      String studentID = widget.studentID;  // Use the studentID passed from the previous screen

      double totalMarks = getTotalMarks();  // Calculate the total marks

      // Prepare the data to store in Firestore
      Map<String, dynamic> marksData = {
        'studentID': studentID,
        'totalMarks': totalMarks,  // Store only total marks
      };

      // Store data under 'marks' -> 'CIE-1' -> studentID
      await FirebaseFirestore.instance
          .collection('marks')
          .doc('CIE-1')
          .set({
        studentID: marksData,
      }, SetOptions(merge: true));  // Merge true allows updates to existing data

      // Optionally, display success message after saving
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
            widget.title,
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
                'Marks distribution',
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(height: 20),
              Table(
                border: TableBorder.all(),
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Question No.', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('a', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('b', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('c', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('d', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  for (var question in questions)
                    TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text('${question['q']}'),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                setState(() {
                                  question['a'] = val;
                                });
                              },
                              decoration: InputDecoration(),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                setState(() {
                                  question['b'] = val;
                                });
                              },
                              decoration: InputDecoration(),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                setState(() {
                                  question['c'] = val;
                                });
                              },
                              decoration: InputDecoration(),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                setState(() {
                                  question['d'] = val;
                                });
                              },
                              decoration: InputDecoration(),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                setState(() {
                                  question['total'] = val;  // Total now directly input
                                });
                              },
                              decoration: InputDecoration(),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 20),
              // Redesigned UI for total marks and marks obtained
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
                          'Total Marks: ${getTotalMarks()}',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: saveMarksToFirestore,
                        child: Text("Save"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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
    );
  }
}