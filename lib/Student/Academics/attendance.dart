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
        // User not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in.")),
        );
        return;
      }

      // Fetch the user's profile document using their unique user ID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Student_users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          semester = userDoc['semester'] ?? 'N/A';
          studentId = userDoc['id'] ?? 'N/A';
        });

        if (semester == null || studentId == null) return;

        try {
          // Access the correct document path in Firestore
          DocumentSnapshot studentDoc = await FirebaseFirestore.instance
              .collection('Attendance')
              .doc(semester) // Semester-level document
              .collection('students')
              .doc(studentId) // Student-level document with student ID as the document ID
              .get();

          if (studentDoc.exists) {
            setState(() {
              attendancePercentage = studentDoc['attendance_percentage'] ?? 0.0;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No attendance record found for this student.")),
            );
            setState(() {
              attendancePercentage = 0.0;
            });
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error fetching attendance data")),
          );
        }
      } else {
        // User profile does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User profile does not exist.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user profile data: $e")),
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
          "Attendance",
          style: TextStyle(fontSize: 25, fontFamily: "Nexa", color: Colors.white),
        ),
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
                      Container(
                        width: 400,
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
                            const Icon(Icons.person, size: 60, color: Colors.blueAccent),
                            const SizedBox(height: 10),
                            Text(
                              "Student ID: $studentId",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Nexa'),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Semester: $semester",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Nexa'),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Attendance: ${attendancePercentage.toStringAsFixed(1)}%",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: attendancePercentage >= 85 ? Colors.green : Colors.red,
                                  fontFamily: 'Nexa'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Pie chart
                      Center(
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
                      ),
                    ],
                  ),
              ],
            ),
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
        titleStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: attendancePercentage,
        color: Colors.green,
        title: '${attendancePercentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

    ];
  }
}
