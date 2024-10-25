import 'package:flutter/material.dart';
import 'package:sam_pro/Admin/Home/Add_student/student.dart';
import 'package:sam_pro/Admin/Home/Add_student/students_list.dart';
import 'package:sam_pro/Admin/Home/Add_teacher/teacher.dart';
import 'package:sam_pro/Admin/Home/Add_teacher/teachers_list.dart';
import 'package:sam_pro/Admin/auth/login.dart';
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
                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => adminlogin()),);
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
       automaticallyImplyLeading: false,
        title: Text("Home"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            _logout(context);
          }, icon: Icon(Icons.logout),color: Colors.black,),
        ],
      ),


      body: Column(
        children: [
          Container(
            height: 3,
            color: Colors.grey,
          ),
           InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => StudentPage(),));
              },
              child: ListTile(
                leading: Icon(Icons.add),
                   title: Text("Students"),
                   trailing: Icon(Icons.arrow_forward)
                 ),
            ),
          Divider(
            height: 3,
          ),

          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherPage(),));
            },
            child: ListTile(
                leading: Icon(Icons.add),
                title: Text("Teachers"),
                trailing: Icon(Icons.arrow_forward)
            ),
          ),

          Divider(
            height: 3,
          ),

          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => StudentsList(),));
            },
            child: ListTile(
                leading: Icon(Icons.person,color: Colors.blue,),
                title: Text("Students List"),
                trailing: Icon(Icons.arrow_forward)
            ),
          ),

          Divider(
            height: 3,
          ),
          InkWell(
            onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => TeachersList(),));
            },
            child: ListTile(
                leading: Icon(Icons.person,color: Colors.orange,),
                title: Text("Teachers List"),
                trailing: Icon(Icons.arrow_forward)
            ),
          ),

          Divider(
            height: 3,
          )
        ],
      ),
    );
  }
}
