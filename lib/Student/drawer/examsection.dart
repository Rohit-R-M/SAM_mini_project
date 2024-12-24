import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

class ExamSectionScreen extends StatelessWidget {
  const ExamSectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            )),
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Exam Notices",
          style: TextStyle(fontFamily: 'Nexa', color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Exam_Notice')
            .orderBy('day', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Exam Notices Available"));
          }

          final notices = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              final title = notice['title'];
              final desc = notice['desc'];
              final fileUrl = notice['fileUrl'];
              final day = (notice['day'] as Timestamp).toDate();

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nexa',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        desc ?? 'No Description',
                        style:
                            const TextStyle(fontSize: 16, fontFamily: 'Nexa'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Posted on: ${day.toLocal()}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Nexa',
                        ),
                      ),
                      const SizedBox(height: 8),
                      fileUrl != null
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PdfViewScreen(pdfUrl: fileUrl),
                                  ),
                                );
                              },
                              child: const Text(
                                "View Notice (PDF)",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueAccent,
                                  fontFamily: 'Nexa',
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
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

class PdfViewScreen extends StatelessWidget {
  final String pdfUrl;

  const PdfViewScreen({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Viewer"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: PDFViewerSection(pdfUrl: pdfUrl),
    );
  }
}

class PDFViewerSection extends StatefulWidget {
  final String pdfUrl;

  const PDFViewerSection({super.key, required this.pdfUrl});

  @override
  _PDFViewerSectionState createState() => _PDFViewerSectionState();
}

class _PDFViewerSectionState extends State<PDFViewerSection> {
  bool _isLoading = true;
  PDFDocument? _document;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      _document = await PDFDocument.fromURL(widget.pdfUrl);
    } catch (error) {
      _document = null;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_document == null) {
      return const Center(
        child: Text(
          "Failed to load PDF",
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    }

    return PDFViewer(
      document: _document!,
      zoomSteps: 1,
    );
  }
}
