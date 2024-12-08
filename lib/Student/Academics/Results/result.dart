import 'package:url_launcher/link.dart' as url_launcher;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sam_pro/Student/Academics/Results/Assignment.dart';
import 'package:sam_pro/Student/Academics/Results/Cie1.dart';
import 'package:sam_pro/Student/Academics/Results/Cie2.dart';



class ResultScreen extends StatefulWidget {
  final String name;
  final String id;
  final String semester;
  final String course;

  const ResultScreen({
    super.key,
    required this.name,
    required this.id,
    required this.semester,
    required this.course,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late List<String> courseNames = [];

  // Function to fetch courses for semester 5
  Future<void> fetchCourseNamesForSemester5() async {
    final collectionRef = FirebaseFirestore.instance.collection('Admin_added_Course');

    try {
      final querySnapshot = await collectionRef.where('semester', isEqualTo: widget.semester).get();

      Set<String> uniqueCourses = Set<String>();

      // Extract course names and add them to the Set (duplicates will be ignored)
      for (var doc in querySnapshot.docs) {
        final courseName = doc.data()['course_name'] as String;
        uniqueCourses.add(courseName);
      }

      // Convert the Set back to a List and update the state
      setState(() {
        courseNames = uniqueCourses.toList();
      });
    } catch (e) {
      print('Error fetching courses: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCourseNamesForSemester5(); // Fetch course names on initialization
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
        title: const Text(
          "Results",
          style: TextStyle(fontSize: 24, fontFamily: "Nexa", color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: courseNames.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display CIE-1, CIE-2, Assignment as smaller, cleaner cards
            _buildResultCard(
              icon: Icons.book,
              title: "CIE-1",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Cie1Screen(
                      id: widget.id,
                      semester: widget.semester,
                      course: courseNames, // Passing the course list
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 12), // Smaller gap between cards
            _buildResultCard(
              icon: Icons.book,
              title: "CIE-2",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Cie2Screen(
                      id: widget.id,
                      semester: widget.semester,
                      course: courseNames,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 12), // Smaller gap between cards
            _buildResultCard(
              icon: Icons.assignment,
              title: "Assignment",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignmentScreen(
                      id: widget.id,
                      semester: widget.semester,
                      course: courseNames,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 12,),
           Container(
                child: Card(
                  elevation: 2,
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.grade_rounded,
                      color: Colors.blueAccent,
                      size: 24,
                    ),
                    title: Text(
                      "SEE",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Nexa",
                        color: Colors.black,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: url_launcher.Link(
                          uri: Uri.parse('http://119.161.97.238:8080/Autonomous/'),
                          builder: (context, followLink) {
                            return ElevatedButton(
                              onPressed: followLink,
                              child: Text("Check Out Result",style: TextStyle(fontFamily: "NexaBold",fontWeight: FontWeight.w900,color: Colors.white),),
                              style: ElevatedButton.styleFrom(
                                elevation: 5,
                                backgroundColor: Colors.blueAccent
                              )
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Reduced padding
        leading: Icon(
          icon,
          size: 24, // Reduced icon size for a more compact card
          color: Colors.blueAccent,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: "Nexa",
            color: Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18, // Smaller arrow icon for consistency
          color: Colors.black,
        ),
        onTap: onTap,
      ),
    );
  }
}