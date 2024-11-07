import 'dart:collection';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:intl/intl.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final CollectionReference fetchnotice =
  FirebaseFirestore.instance.collection('Posted_Notice');

  HashMap<String, dynamic> noticeMap = HashMap();
  List<Map<String, dynamic>> noticeList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Notice",
          style:
          TextStyle(fontSize: 25, fontFamily: "Nexa", color: Colors.white),
        ),
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      _showPdfDialog(context, notice['fileUrl']);
                    },
                    child: Padding(
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
                                fontFamily: 'Nexa',
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              notice['day'] != null && notice['day'] is Timestamp
                                  ? DateFormat('dd-MM-yyyy').format((notice['day'] as Timestamp).toDate())
                                  : 'No Date',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                  fontFamily: 'NexaBold',
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      notice['desc'] ?? 'No Description',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                          fontFamily: 'NexaBold',
                          fontWeight: FontWeight.w900
                      ),
                    ),
                  ),
                  const Divider(thickness: 1.5),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showPdfDialog(BuildContext context, String pdfUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewScreen(pdfUrl: pdfUrl),
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
      print("Attempting to load PDF from: ${widget.pdfUrl}");
      _document = await PDFDocument.fromURL(widget.pdfUrl);
      print("PDF loaded successfully");
    } catch (error) {
      print("Error loading PDF: $error");
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
      return Center(
        child: Text(
          "Failed to load PDF",
          style: const TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    }

    return PDFViewer(
      document: _document!,
      zoomSteps: 1,
    );
  }
}