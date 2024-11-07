import 'package:flutter/material.dart';
import 'package:sam_pro/Admin/Course/CourseAdd.dart';
import 'package:sam_pro/Admin/Course/CourseList.dart';
import 'package:sam_pro/Admin/Home/Add_student/student.dart';
import 'package:sam_pro/Admin/Home/Add_student/students_list.dart';
import 'package:sam_pro/Admin/Home/Add_teacher/teacher.dart';
import 'package:sam_pro/Admin/Home/Add_teacher/teachers_list.dart';
import 'package:sam_pro/Admin/Home/Notice.dart';
import 'package:sam_pro/rolescreen.dart';
class adminhomepage extends StatelessWidget {
  adminhomepage({super.key});


  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Rolescreen()),);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        title: Text("Admin Home", style: TextStyle(fontWeight: FontWeight.bold,
            fontFamily: 'Nexa',
            color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {

            },
            icon: Icon(Icons.notifications),
            color: Colors.white,
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.admin_panel_settings, size: 50,
                      color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Manage your portal',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout'),
              onTap: () {
                _logout(context);
              },
            ),

          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(height: 3, color: Colors.grey.shade300),

            Container(
              width: 500,
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white54,

              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildIconButton(context, "Student", Icons.person_add,
                            Colors.blue.shade50, Colors.blueAccent,
                            StudentPage()),
                        _buildIconButton(
                            context, "Teacher", Icons.person_add_alt_1,
                            Colors.orange.shade50, Colors.orangeAccent,
                            TeacherPage()),
                      ],
                    ),
                  ),

                  SizedBox(height: 20,),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildIconButton(context, "Students List", Icons.group,
                            Colors.blue.shade50, Colors.blueAccent,
                            StudentsList()),
                        _buildIconButton(context, "Teachers List", Icons.groups,
                            Colors.orange.shade50, Colors.orangeAccent,
                            TeachersList()),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddNotice()));
                },
                child: ListTile(
                  leading: Icon(Icons.note_add, color: Colors.redAccent),
                  title: Text("Post Notice", style: TextStyle(
                      fontFamily: 'Nexa', fontSize: 18 )),
                  trailing: Icon(Icons.arrow_forward_ios),
                  tileColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AdminCourseAdd()));
                },
                child: ListTile(
                  leading: Icon(Icons.add_box_rounded, color: Colors.green),
                  title: Text("Add Course", style: TextStyle(
                      fontFamily: 'Nexa', fontSize: 18)),
                  trailing: Icon(Icons.arrow_forward_ios),
                  tileColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            SizedBox(height: 20,),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: 1000,
                height: 150,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _courseadding(
                          context,
                          "I Sem",
                          "Course",
                          Icons.list,
                          Colors.red.shade50,
                          Colors.redAccent,
                          AdminCourseList()),

                      _courseadding(
                          context,
                          "II Sem",
                          "Course",
                          Icons.list,
                          Colors.purple.shade50,
                          Colors.purpleAccent,
                          AdminCourseList()),

                      _courseadding(
                          context,
                          "III Sem",
                          "Course",
                          Icons.list,
                          Colors.red.shade50,
                          Colors.redAccent,
                          AdminCourseList()),

                      _courseadding(
                          context,
                          "IV Sem",
                          "Course",
                          Icons.list,
                          Colors.purple.shade50,
                          Colors.purpleAccent,
                          AdminCourseList()),

                      _courseadding(
                          context,
                          "V Sem",
                          "Course",
                          Icons.list,
                          Colors.red.shade50,
                          Colors.redAccent,
                          AdminCourseList()),

                      _courseadding(
                          context,
                          "VI Sem",
                          "Course",
                          Icons.list,
                          Colors.purple.shade50,
                          Colors.purpleAccent,
                          AdminCourseList()),

                      _courseadding(
                          context,
                          "VII Sem",
                          "Course",
                          Icons.list,
                          Colors.red.shade50,
                          Colors.redAccent,
                          AdminCourseList()),

                      _courseadding(
                          context,
                          "VIII Sem",
                          "Course",
                          Icons.list,
                          Colors.purple.shade50,
                          Colors.purpleAccent,
                          AdminCourseList()),

                    ],
                  ),
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }
   Widget _buildIconButton(BuildContext context, String label, IconData icon, Color bgColor, Color iconColor, Widget targetPage) {
     return Container(
       width: 100,
       height: 100,
       decoration: BoxDecoration(
         color: bgColor,
         borderRadius: BorderRadius.circular(12),
         boxShadow: [
           BoxShadow(
             color: Colors.grey.withOpacity(0.3),
             spreadRadius: 2,
             blurRadius: 5,
             offset: Offset(0, 3),
           ),
         ],
       ),
       child: InkWell(
         onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage));
         },
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(icon, size: 40, color: iconColor),
             SizedBox(height: 8),
             Text(label, style: TextStyle(fontFamily: 'Nexa', fontWeight: FontWeight.w900)),
           ],
         ),
       ),
     );
  }
}

Widget _courseadding(BuildContext context, String label1,String label2, IconData icon, Color bgColor, Color iconColor, Widget targetPage) {
  return Container(
    width: 100,
    height: 120,
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: iconColor),
          SizedBox(height: 8),
          Text(label1, style: TextStyle(fontFamily: 'Nexa', fontWeight: FontWeight.w900)),
          Text(label2, style: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900)),
        ],
      ),
    ),
  );
}