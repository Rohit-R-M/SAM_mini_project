import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewAchievements extends StatelessWidget {
  final String id;
  final String semester;

  const ViewAchievements({super.key, required this.id, required this.semester});

  Future<void> _openPDF(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open PDF at $url';
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

          // Group achievements by category
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
                    fontFamily: "Nexa"
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement['title'] ?? 'Untitled',
                              style: const TextStyle(
                                fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                fontFamily: "NexaBold"
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              achievement['description'] ?? 'No description provided.',
                              style: const TextStyle(fontSize: 14,fontFamily: "NexaBold",fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 12),
                            if (achievement['imageUrl'] != null)
                              Image.network(
                                achievement['imageUrl'],
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            if (achievement['pdfUrl'] != null)
                              TextButton.icon(
                                onPressed: () {
                                  _openPDF(achievement['pdfUrl']);
                                },
                                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                label: const Text("Open PDF"),
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
