
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddNotice extends StatefulWidget {
  const AddNotice({super.key});

  @override
  State<AddNotice> createState() => _AddNoticeState();
}

class _AddNoticeState extends State<AddNotice> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  final _noticesCollection = FirebaseFirestore.instance.collection('Posted_Notice');

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> postNotice() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final noticeId = DateTime.now().millisecondsSinceEpoch.toString();
      await _noticesCollection.doc(noticeId).set({
        'title': _titleController.text,
        'desc': _descController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notice Posted Successfully")),
      );
      _formKey.currentState!.reset(); // Reset form fields
      _titleController.clear();
      _descController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post notice: $e")),
      );
    }
  }

  Future<void> deleteNotice(String docId) async {
    try {
      await _noticesCollection.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notice Deleted Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete notice: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Post Notice"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const Divider(indent: 10, endIndent: 10, thickness: 2),

            Container(
              height: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream: _noticesCollection.snapshots(),
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

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final notice = doc.data() as Map<String, dynamic>;

                      return  ListTile(
                          title: Text(
                            notice['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            notice['desc'] ?? 'No Description',
                            style: const TextStyle(fontSize: 16),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteNotice(doc.id),
                          ),
                      );
                    },

                  );
                },
              ),
            ),

            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _titleController,
                maxLength: 50,
                maxLines: 2,
                decoration:  InputDecoration(
                  label: Text("Add Title"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Please enter the title" : null,
              ),
            ),



            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _descController,
                maxLength: 300,
                maxLines: 7,
                decoration: InputDecoration(
                  labelText: "Add Description",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Please enter the description" : null,
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: postNotice,
              child: const Text("Post Notice"),
            ),
          ],
        ),
      ),
    );
  }
}
