import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignmentScreen extends StatefulWidget {
  final String id;
  final String semester;
  final List<String> course;

  const AssignmentScreen({
    super.key,
    required this.id,
    required this.semester,
    required this.course,
  });

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  bool isLoading = true;
  Map<String, double> courseMarks = {}; // Map to store marks for each course

  @override
  void initState() {
    super.initState();
    fetchMarksData();
  }

  // Fetch marks data for each course
  Future<void> fetchMarksData() async {
    setState(() {
      isLoading = true;
      courseMarks.clear(); // Clear previous data
    });

    try {
      // Print the list of courses received from the previous screen
      print("List of Courses: ${widget.course}");

      // Iterate through the list of courses passed from the previous screen
      for (String course in widget.course) {
        // Fetch marks document for the current course
        DocumentSnapshot marksDoc = await FirebaseFirestore.instance
            .collection('marks')
            .doc(widget.semester)
            .collection(course)
            .doc('assignment') // Assuming marks are stored under 'assignment'
            .get();

        if (marksDoc.exists) {
          final Map<String, dynamic>? data = marksDoc.data() as Map<String, dynamic>?;

          if (data != null && data.containsKey(widget.id)) {
            var studentData = data[widget.id];
            courseMarks[course] = studentData['totalMarks']?.toDouble() ?? 0.0;
          } else {
            courseMarks[course] = 0.0; // No marks found for the student in this course
          }
        } else {
          courseMarks[course] = 0.0; // Document does not exist
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching marks data: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Assignment marks",
          style: TextStyle(fontSize: 25, fontFamily: "Nexa", color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchMarksData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: courseMarks.length,
                    itemBuilder: (context, index) {
                      String courseName = courseMarks.keys.elementAt(index);
                      double marks = courseMarks[courseName]!;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 5,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.school, size: 60, color: Colors.blueAccent),
                            const SizedBox(height: 10),
                            Text(
                              "$courseName",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Nexa'),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Total Marks: $marks",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Nexa'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}