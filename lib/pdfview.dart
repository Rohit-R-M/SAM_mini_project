import 'package:flutter/material.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

class PDFViewerSection extends StatefulWidget {
  final String fileUrl;

  const PDFViewerSection({super.key, required this.fileUrl});

  @override
  _PDFViewerSectionState createState() => _PDFViewerSectionState();
}

class _PDFViewerSectionState extends State<PDFViewerSection> {
  late Future<PDFDocument> document;

  @override
  void initState() {
    super.initState();
    document = _loadPdf();
  }

  Future<PDFDocument> _loadPdf() async {
    try {
      print("Attempting to load PDF from: ${widget.fileUrl}");
      final doc = await PDFDocument.fromURL(widget.fileUrl).timeout(const Duration(seconds: 30));
      print("PDF loaded successfully");
      return doc;
    } catch (error) {
      print("Error loading PDF: $error");
      throw Exception("Could not load PDF: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PDFDocument>(
      future: document,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error.toString());
        }

        return PDFViewer(
          document: snapshot.data!,
        );
      },
    );
  }

  Widget _buildErrorScreen(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Failed to load PDF:\n$error",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                document = _loadPdf();
              });
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
