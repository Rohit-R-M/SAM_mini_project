import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  // Firestore collection reference
  final CollectionReference fetchnotice =
  FirebaseFirestore.instance.collection('Posted_Notice');

  // HashMap to store notices temporarily
  HashMap<String, dynamic> noticeMap = HashMap();

  // List to store the converted notices
  List<Map<String, dynamic>> noticeList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Notice Board"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fetchnotice.snapshots(), // Firestore real-time updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching notices"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notices available"));
          }

          // Clear previous data
          noticeMap.clear();
          noticeList.clear();

          // Populate the HashMap with Firestore data
          for (var doc in snapshot.data!.docs) {
            noticeMap[doc.id] = doc.data();
          }

          // Convert HashMap values to List<Map<String, dynamic>>
          noticeList = noticeMap.values
              .map((e) => e as Map<String, dynamic>) // Type casting
              .toList();

          return ListView.builder(
            itemCount: noticeList.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> notice = noticeList[index];

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    notice['title'] ?? 'No Title',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    notice['desc'] ?? 'No Description',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
