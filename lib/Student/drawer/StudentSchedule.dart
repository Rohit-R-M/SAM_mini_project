import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudScheduleScreen extends StatefulWidget {
  const StudScheduleScreen({super.key});

  @override
  State<StudScheduleScreen> createState() => _StudScheduleScreenState();
}

class _StudScheduleScreenState extends State<StudScheduleScreen> {
  String selectedDay = "Monday"; // Default selected day
  Map<String, List<Map<String, String>>> timetable = {};

  final List<String> weekDays = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ]; // Define the week days in order

  @override
  void initState() {
    super.initState();
    fetchTimetable();
  }

  Future<void> fetchTimetable() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('timetable')
          .doc('weekdays')
          .get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        data.forEach((day, subjects) {
          List<Map<String, String>> subjectList = [];
          if (subjects is List) {
            for (var subjectData in subjects) {
              if (subjectData is Map<String, dynamic>) {
                subjectList.add({
                  'subject': subjectData['subject'] ?? '',
                  'time': subjectData['time'] ?? '',
                });
              }
            }
          }
          timetable[day] = subjectList;
        });
        setState(() {}); // Refresh UI with the fetched data
      }
    } catch (e) {
      print("Error fetching timetable: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Schedules",
          style:
          TextStyle(fontSize: 25, fontFamily: "Nexa", color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Horizontal scrollable week days
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: weekDays.map((day) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = day; // Update selected day
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: selectedDay == day ? Colors.blue : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selectedDay == day ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Displaying periods for the selected day or holiday message for Sunday
            Expanded(
              child: selectedDay == "Sunday"
                  ? Center(
                child: Text(
                  "Holiday",
                  style: TextStyle(
                    fontFamily: 'Nexa',
                    fontSize: 24,
                    color: Colors.red,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: timetable[selectedDay]?.length ?? 0,
                itemBuilder: (context, index) {
                  Map<String, String> subjectData = timetable[selectedDay]![index];
                  String subject = subjectData['subject']!;
                  String time = subjectData['time']!;
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(subject),
                      subtitle: Text(time),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
