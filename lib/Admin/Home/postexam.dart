import 'package:flutter/material.dart';

class PostExamNotice extends StatefulWidget {
  const PostExamNotice({super.key});

  @override
  State<PostExamNotice> createState() => _PostExamNoticeState();
}

class _PostExamNoticeState extends State<PostExamNotice> {
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

    );
  }
}
