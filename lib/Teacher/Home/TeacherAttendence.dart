import 'package:flutter/material.dart';
import 'package:sam_pro/Teacher/Attendance/Teacheraddattemdance.dart';

class TeacherAttendanceScreen extends StatelessWidget {
  const TeacherAttendanceScreen({super.key});


  @override
  Widget build(BuildContext context) {
    List<String> semesters = [
      '1', '2', '3', '4', '5', '6', '7', '8'
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
                  child: Container(
                    height: 50,
                    width: 400,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttendancePage(semester: semester),
                          ),
                        );
                      },
                      child: Text('Mark Attendance for Semester $semester',style: TextStyle(fontSize: 18,fontFamily: 'NexaBold',fontWeight: FontWeight.w900),),
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blue)
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
      ),

    );
  }
}


