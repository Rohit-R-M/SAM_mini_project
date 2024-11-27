import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

class ViewNotesScreen extends StatefulWidget {
  final String courseName;

  const ViewNotesScreen({super.key, required this.courseName});

  @override
  State<ViewNotesScreen> createState() => _ViewNotesScreenState();
}

class _ViewNotesScreenState extends State<ViewNotesScreen> {
  final List<String> subCollections = [
    "Syllabus copy",
    "Unit 1",
    "Unit 2",
    "Unit 3",
    "Unit 4",
    "Unit 5",
    "Laboratory Syllabus copy",
    "Other Materials"
  ];
  String? selectedItem = "Syllabus copy"; // Selected dropdown item

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios_sharp,color: Colors.white,)),
        title: Text(
          "${widget.courseName}",
          style: TextStyle(fontFamily: 'Nexa',color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButton<String>(
                value: selectedItem,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down,),
                iconSize: 36,
                underline: const SizedBox(), // Remove the underline
                items: subCollections.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,fontFamily: "NexaBold"),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedItem = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            // Display the dynamic list of notes
            selectedItem != null
                ? Expanded(
              child: FutureBuilder(
                future: _getNotes(selectedItem!), // Fetch notes dynamically
                builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Error fetching data. Please try again later.",
                        style: TextStyle(fontSize: 16, color: Colors.red,fontFamily: "NexaBold"),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No notes available in this category.",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,fontFamily: "NexaBold"),
                      ),
                    );
                  }
                  final notes = snapshot.data!;
                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shadowColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.blue[100],
                        child: ListTile(
                          leading: const Icon(Icons.picture_as_pdf, color: Colors.blueAccent),
                          title: Text(
                            note['chapter_name'],
                            style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: "Nexa"),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () async {
                            final pdfUrl = note['file_url'];
                            final pdfDocument = await PDFDocument.fromURL(pdfUrl);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PDFViewer(document: pdfDocument),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            )
                : const Center(child: Text("Please select a category",style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,fontFamily: "NexaBold"),)
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getNotes(String category) async {
    final collectionRef = FirebaseFirestore.instance.collection('notes');
    final courseDoc = await collectionRef
        .doc(widget.courseName)
        .collection(category)
        .get();

    return courseDoc.docs.map((doc) => doc.data()).toList();
  }
}