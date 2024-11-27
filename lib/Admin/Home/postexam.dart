import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostExamNotice extends StatefulWidget {
  const PostExamNotice({super.key});

  @override
  State<PostExamNotice> createState() => _PostExamNoticeState();
}

class _PostExamNoticeState extends State<PostExamNotice> {


  final _formKey = GlobalKey<FormState>();

  final CollectionReference _ep = FirebaseFirestore.instance.collection("Exam_Notice");

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  Future<void> postexam() async {

    if(!_formKey.currentState!.validate()) return;

    try{
      await _ep.doc().set({
        'title': _titleController.text,
        'desc': _descController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Posted Sucessful!")));

      _titleController.clear();
      _descController.clear();

    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to post!")));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        backgroundColor: Colors.blueAccent,
        title: Text("Exam Notice",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Nexa',
                color: Colors.white)),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: _titleController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    label: Text("Title",style: TextStyle(fontFamily: 'NexaBold',fontWeight: FontWeight.w900)),
                    border: OutlineInputBorder()
                  ),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Please enter the title';
                    }
                    return null;
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: _descController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      label: Text("Description",style: TextStyle(fontFamily: 'NexaBold',fontWeight: FontWeight.w900),),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder()
                  ),
                  maxLines: 5,
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Please enter the Description';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 15,),
              SizedBox(
                width: 100,
                child: ElevatedButton(onPressed: (){
                  postexam();
                }, child: Text("Post",style: TextStyle(fontFamily: 'NexaBold',fontWeight: FontWeight.w900))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
