import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sam_pro/Student/notification.dart';

class attendancescreen extends StatefulWidget {
  const attendancescreen({super.key});

  @override
  State<attendancescreen> createState() => _attendancescreenState();
}

class _attendancescreenState extends State<attendancescreen> {

  double attendancePercentage = 0.0; // Attendance percentage of the student
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    // Fetch the attendance data when the screen loads
    fetchAttendanceData();
  }

  // Fetch the attendance data from Firestore
  Future<void> fetchAttendanceData() async {
    try {
      String studentId = "student123";
      String semester = "Fall 2024";

      // Fetch the attendance document for this student
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('Attendance')
          .doc(semester)
          .collection('students')
          .doc(studentId)
          .get();

      if (studentDoc.exists) {
        // Get the attendance percentage from the document
        setState(() {
          attendancePercentage = studentDoc['attendance_percentage'] ?? 0.0;
          isLoading = false;
        });
      } else {
        setState(() {
          attendancePercentage = 0.0;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching attendance data: $e");
      setState(() {
        isLoading = false;
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
        title: const Text(
          "Attendance",
          style:
          TextStyle(fontSize: 25, fontFamily: "Nexa", color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    const Text(
                      "Your Attendance Percentage",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    PieChart(
                      PieChartData(
                        sections: showingSections(),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),

    );
  }

  List<PieChartSectionData> showingSections() {
    return [
      PieChartSectionData(
        value: attendancePercentage,
        color: Colors.green,
        title: '${attendancePercentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: 100 - attendancePercentage,
        color: Colors.red,
        title: '${(100 - attendancePercentage).toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }
}



