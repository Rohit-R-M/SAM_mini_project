import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class StudentsList extends StatefulWidget {
  const StudentsList({super.key});

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  final DatabaseReference student= FirebaseDatabase.instance.ref('Admin_Students_List');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios)),
        title: Text("Students List"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          // Controls the height of the divider
          child: Container(
            color: Colors.grey, // Divider color
            height: 2.0, // Divider thickness
          ),
        ),
      ),


      body: Column(
        children: [
          Expanded(
              child: FirebaseAnimatedList(
                query: student,
                itemBuilder: (context, snapshot, animation, index) {
                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.perm_identity),
                        ),
                        title: Text(snapshot.child('id').value.toString()),
                        subtitle: Text(snapshot.child("email").value.toString()),
                        trailing: Icon(Icons.check,color: Colors.green,),
                      ),
                      Divider(
                        thickness: 2,
                        indent: 5,
                        endIndent: 5,
                      ),
                    ],
                  );
                },

              )
          ),

        ],
      ),
    );
  }
}
