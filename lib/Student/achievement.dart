import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class ViewAchievements extends StatelessWidget {
  final String id;
  final String semester;

  const ViewAchievements({super.key, required this.id, required this.semester});

  Future<void> _viewPDF(BuildContext context, String url) async {
    try {
      PDFDocument document = await PDFDocument.fromURL(url);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(document: document),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load PDF: $e')),
      );
    }
  }

  Future<void> _downloadPDF(BuildContext context, String url, String title) async {
    try {
      // Define the path to the Downloads directory
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }

      // Create the full file path
      final filePath = '${downloadsDir.path}/$title.pdf';
      Dio dio = Dio();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading...')),
      );

      // Download the file using Dio
      await dio.download(url, filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download complete! File saved at $filePath'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  Future<void> _editAchievement(
      BuildContext context, String docId, Map<String, dynamic> data) async {
    TextEditingController titleController =
    TextEditingController(text: data['title']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Achievement"),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('students_achievements')
                      .doc(semester)
                      .collection('student Id')
                      .doc(id)
                      .collection('achievements')
                      .doc(docId)
                      .update({'title': titleController.text});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Achievement updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update achievement: $e')),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAchievement(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('students_achievements')
          .doc(semester)
          .collection('student Id')
          .doc(id)
          .collection('achievements')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Achievement deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete achievement: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: const Text(
          "Achievements",
          style: TextStyle(fontSize: 24, fontFamily: "Nexa", color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students_achievements')
            .doc(semester)
            .collection('student Id')
            .doc(id)
            .collection('achievements')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading achievements'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No achievements found'));
          }

          final achievements = snapshot.data!.docs;

          final categoryGroups = <String, List<QueryDocumentSnapshot>>{};
          for (var achievement in achievements) {
            final category = achievement['category'] ?? 'Other';
            categoryGroups.putIfAbsent(category, () => []).add(achievement);
          }

          return ListView(
            padding: const EdgeInsets.all(5),
            children: categoryGroups.entries.map((entry) {
              final category = entry.key;
              final items = entry.value;

              return ExpansionTile(
                title: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "Nexa",
                  ),
                ),
                children: items.map((achievement) {
                  return Container(
                    width: 400,
                    child: Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    achievement['title'] ?? 'Untitled',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: "NexaBold",
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    achievement['description'] ??
                                        'No description provided.',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: "NexaBold",
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  if (achievement['pdfUrl'] != null)
                                    TextButton.icon(
                                      onPressed: () {
                                        _viewPDF(context, achievement['pdfUrl']);
                                      },
                                      icon: const Icon(FontAwesomeIcons.book,
                                          color: Colors.red),
                                      label: const Text("Certificate"),
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                switch (value) {
                                  case 'edit':
                                    _editAchievement(
                                      context,
                                      achievement.id,
                                      achievement.data() as Map<String, dynamic>,
                                    );
                                    break;
                                  case 'delete':
                                    _deleteAchievement(context, achievement.id);
                                    break;
                                  case 'download':
                                    if (achievement['pdfUrl'] != null) {
                                      _downloadPDF(
                                          context,
                                          achievement['pdfUrl'],
                                          achievement['title'] ?? 'Certificate');
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('No PDF available')),
                                      );
                                    }
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                                const PopupMenuItem(
                                  value: 'download',
                                  child: Text('Download'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

class PDFViewerPage extends StatelessWidget {
  final PDFDocument document;

  const PDFViewerPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        backgroundColor: Colors.blueAccent,
      ),
      body: PDFViewer(
        document: document,
        lazyLoad: false,
        scrollDirection: Axis.vertical,
      ),
    );
  }
}
