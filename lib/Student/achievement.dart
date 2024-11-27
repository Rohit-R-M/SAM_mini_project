import 'package:flutter/material.dart';

class achievementpage extends StatefulWidget {
  const achievementpage({super.key});

  @override
  State<achievementpage> createState() => _achievementpageState();
}

class _achievementpageState extends State<achievementpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios_sharp,color: Colors.white,)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: Text("Achievements",style: TextStyle(fontSize: 25, fontFamily: "Nexa", color: Colors.white),),
      ),
    );
  }
}
