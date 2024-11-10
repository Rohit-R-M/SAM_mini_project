import 'package:flutter/material.dart';
import 'package:sam_pro/Teacher/Attendance/Teacheraddattemdance.dart';

class TeacherAttendanceScreen extends StatelessWidget {
  const TeacherAttendanceScreen({super.key});


  @override
  Widget build(BuildContext context) {
    List<String> semesters = [
      'Semester 1', 'Semester 2', 'Semester 3', 'Semester 4',
      'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8'
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        backgroundColor: Colors.blueAccent,
        title: Text(
          "Attendance",
          style: TextStyle(fontFamily: 'Nexa',color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loop to create buttons for all semesters
              ...semesters.map((semester) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendancePage(semester: semester),
                        ),
                      );
                    },
                    child: Text('Mark Attendance for $semester'),
                  ),
                );
              }).toList(),
            ],
          ),
      ),

    );
  }
}


