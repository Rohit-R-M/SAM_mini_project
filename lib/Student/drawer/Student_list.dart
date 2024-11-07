import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:sam_pro/Student/notification.dart';

class StudentsList extends StatefulWidget {
  const StudentsList({super.key});

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {

  final DatabaseReference ref = FirebaseDatabase.instance.ref('Student_list');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        title: const Text(
          "Students List",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500,fontFamily: 'Nexa',color: Colors.white),
        ),
        centerTitle: true,
      ),




      body: Column(
        children: [
          Expanded(
              child: FirebaseAnimatedList(
                  query: ref,
                  itemBuilder: (context, snapshot, animation, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5),
                      child: Card(
                        color: Colors.blue[50],
                        elevation: 5,
                        child: ListTile(
                          title: Text(snapshot.child('name').value.toString()),
                          subtitle: Text(snapshot.child("usn").value.toString()),
                        ),
                      ),
                    );
                  },
              ),
          ),
        ],
      ),
    );
  }
}
