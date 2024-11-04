import 'package:flutter/material.dart';
import 'package:sam_pro/Admin/Home/Add_student/student.dart';
import 'package:sam_pro/Admin/Home/Add_student/students_list.dart';
import 'package:sam_pro/Admin/Home/Add_teacher/teacher.dart';
import 'package:sam_pro/Admin/Home/Add_teacher/teachers_list.dart';
import 'package:sam_pro/Admin/Home/Notice.dart';
import 'package:sam_pro/rolescreen.dart';
class adminhomepage extends StatelessWidget {
   adminhomepage({super.key});


   void _logout(BuildContext context){
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
                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Rolescreen()),);
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
        title: Text("Admin Home", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {

            },
            icon: Icon(Icons.notifications_none_sharp),
            color: Colors.black,
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
                  Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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

            // "Add" Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Add",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.blueAccent),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIconButton(context, "Student", Icons.person_add, Colors.blue.shade50, Colors.blueAccent, StudentPage()),
                  _buildIconButton(context, "Teacher", Icons.person_add_alt_1, Colors.orange.shade50, Colors.orangeAccent, TeacherPage()),
                ],
              ),
            ),

            // "View" Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "View",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.blueAccent),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIconButton(context, "Students List", Icons.group, Colors.blue.shade50, Colors.blueAccent, StudentsList()),
                  _buildIconButton(context, "Teachers List", Icons.groups, Colors.orange.shade50, Colors.orangeAccent, TeachersList()),
                ],
              ),
            ),

            // Post Notice
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddNotice()));
                },
                child: ListTile(
                  leading: Icon(Icons.edit_notifications, color: Colors.redAccent),
                  title: Text("Post Notice", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  trailing: Icon(Icons.arrow_forward_ios),
                  tileColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
             Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
           ],
         ),
       ),
     );
  }
}
