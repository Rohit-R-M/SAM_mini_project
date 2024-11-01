import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminNoticeScreen extends StatefulWidget {
  const AdminNoticeScreen({super.key});

  @override
  State<AdminNoticeScreen> createState() => _AdminNoticeScreenState();
}

class _AdminNoticeScreenState extends State<AdminNoticeScreen> {
  final CollectionReference fetchnotice =
  FirebaseFirestore.instance.collection('Posted_Notice');

  HashMap<String, dynamic> noticeMap = HashMap();
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
        title: const Text("Admin Notice Board"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fetchnotice.snapshots(),
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

          noticeMap.clear();
          noticeList.clear();

          for (var doc in snapshot.data!.docs) {
            noticeMap[doc.id] = doc.data();
          }

          noticeList = noticeMap.values
              .map((e) => e as Map<String, dynamic>)
              .toList();

          return ListView.builder(
            itemCount: noticeList.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> notice = noticeList[index];
              String noticeId = noticeMap.keys.elementAt(index);

              return Container(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notice['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),

                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              notice['date'] != null
                                  ? DateFormat('dd-MM-yyyy').format((notice['date'] as Timestamp).toDate())
                                  : 'No Date',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),



                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        notice['desc'] ?? 'No Description',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),



                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _editNotice(noticeId, notice);
                            },
                            child: const Text("Edit"),
                          ),
                          TextButton(
                            onPressed: () {
                              _deleteNotice(noticeId);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1.5),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _editNotice(String noticeId, Map<String, dynamic> notice) {
    final titleController = TextEditingController(text: notice['title']);
    final descController = TextEditingController(text: notice['desc']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Notice"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await fetchnotice.doc(noticeId).update({
                  'title': titleController.text,
                  'desc': descController.text,
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Notice updated successfully")),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteNotice(String noticeId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Notice"),
          content: const Text("Are you sure you want to delete this notice?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await fetchnotice.doc(noticeId).delete();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Notice deleted successfully")),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
