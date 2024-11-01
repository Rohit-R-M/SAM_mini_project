import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:sam_pro/Student/notification.dart';

class TeacherList extends StatefulWidget {
  const TeacherList({super.key});

  @override
  State<TeacherList> createState() => _TeacherListState();
}

class _TeacherListState extends State<TeacherList> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('Teacher_list');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios)
        ),
        centerTitle: true,
        title: Text("Teacher List"),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => notificationscreen(),));
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
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
              query: ref,
              itemBuilder: (context, snapshot, animation, index) {
                return ListTile(
                  title: Text(snapshot.child('name').value.toString()),
                  subtitle: Text(snapshot.child("usn").value.toString()),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
