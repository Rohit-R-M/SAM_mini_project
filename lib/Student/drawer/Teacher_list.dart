import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FacultyListView extends StatefulWidget {
  const FacultyListView({super.key});

  @override
  State<FacultyListView> createState() => _FacultyListViewState();
}

class _FacultyListViewState extends State<FacultyListView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          "Faculty List",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            fontFamily: 'Nexa',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Teacher_users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Teacher found.'));
          }

          final teachers = snapshot.data!.docs;

          // Group teachers by their branch
          final Map<String, List<QueryDocumentSnapshot>> branchGroups = {};

          for (var teacher in teachers) {
            final branch = teacher['branch_name'] ?? 'Unknown Branch';

            if (!branchGroups.containsKey(branch)) {
              branchGroups[branch] = [];
            }
            branchGroups[branch]!.add(teacher);
          }


          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: branchGroups.entries.map((branchEntry) {
              final branch = branchEntry.key;
              final branchTeachers = branchEntry.value;

              return ExpansionTile(
                title: Text(
                  branch,
                  style: const TextStyle(fontFamily: 'Nexa'),
                ),
                children: branchTeachers.map((teacher) {
                  return ListTile(
                    leading: CircleAvatar(
                      child:Icon(Icons.person,color: Colors.black,),
                    ),
                    title: Text(
                      teacher['name'] ?? 'Name',
                      style: const TextStyle(fontSize: 15, fontFamily: "Nexa"),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacher['phone_no'] ?? 'Phone Number',
                          style: const TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
                        ),
                        Text(
                          teacher['email'] ?? 'Email',
                          style: const TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
