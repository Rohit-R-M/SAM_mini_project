import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  double attendancePercentage = 0.0;
  bool isLoading = true;
  String? semester;
  String? studentId;
  List<String> courseNames = [];
  String? selectedCourse; // To hold the selected course name

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    setState(() => isLoading = true);

    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not logged in.")));
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Student_users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          semester = userDoc['semester'];
          studentId = userDoc['id'];
        });

        if (semester != null && studentId != null) {
          await fetchCoursesForSemester();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User profile does not exist.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchCoursesForSemester() async {
    try {
      QuerySnapshot courseSnapshot = await FirebaseFirestore.instance
          .collection('Admin_added_Course')
          .where('semester', isEqualTo: semester)
          .get();

      List<String> fetchedCourseNames =
      courseSnapshot.docs.map((doc) => doc['course_name'] as String).toList();

      if (fetchedCourseNames.isNotEmpty) {
        setState(() {
          courseNames = fetchedCourseNames;
          selectedCourse = courseNames[0]; // Set the first course as the selected course
        });

        // Fetch attendance data for the first course
        await fetchAttendanceDataForCourse(selectedCourse!);
      } else {
        setState(() {
          courseNames = [];
          attendancePercentage = 0.0; // No courses, reset attendance to 0%
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error fetching courses: $e")));
    }
  }


  Future<void> fetchAttendanceDataForCourse(String courseName) async {
    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('Attendance')
          .doc(semester)
          .collection(courseName) // Access subcollection for the specific course
          .doc(studentId)
          .get();

      if (studentDoc.exists) {
        // Fetching totalClasses and attendedClasses as integers from Firestore
        int totalClasses = studentDoc['total'] ?? 0;
        int attendedClasses = studentDoc['present'] ?? 0;

        if (totalClasses > 0) {
          setState(() {
            attendancePercentage = (attendedClasses / totalClasses) * 100;
          });
        } else {
          setState(() {
            attendancePercentage = 0.0;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No attendance record found for this course.")));
        setState(() => attendancePercentage = 0.0);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching attendance data: $e")));
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
        title: const Text("Attendance", style: TextStyle(fontSize: 25, fontFamily: "Nexa", color: Colors.white)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchUserProfile,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildProfileCard(),
                      const SizedBox(height: 30),
                      buildCourseList(),
                      const SizedBox(height: 30),
                      buildPieChart(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileCard() {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 10, spreadRadius: 5, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 60, color: Colors.blueAccent),
          const SizedBox(height: 10),
          Text("Student ID: $studentId", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Nexa')),
          const SizedBox(height: 8),
          Text("Semester: $semester", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Nexa')),
          const SizedBox(height: 8),
          Text(
            "Attendance: ${attendancePercentage.toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: attendancePercentage >= 85 ? Colors.green : Colors.red,
              fontFamily: 'Nexa',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCourseList() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courseNames.length,
        itemBuilder: (context, index) {
          bool isSelected = courseNames[index] == selectedCourse; // Check if the current course is selected

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCourse = courseNames[index]; // Update the selected course
                });
                fetchAttendanceDataForCourse(selectedCourse!); // Fetch attendance data for the selected course
              },
              child: Chip(
                label: Text(courseNames[index]),
                backgroundColor: isSelected ? Colors.blueAccent : Colors.grey, // Set background color based on selection
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildPieChart() {
    return Center(
      child: SizedBox(
        height: 300,
        child: PieChart(
          PieChartData(
            sections: showingSections(),
            borderData: FlBorderData(show: false),
            centerSpaceRadius: 50,
            sectionsSpace: 2,
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return [
      PieChartSectionData(
        value: 100 - attendancePercentage,
        color: Colors.red,
        title: '${(100 - attendancePercentage).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        value: attendancePercentage,
        color: Colors.green,
        title: '${attendancePercentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }
}
