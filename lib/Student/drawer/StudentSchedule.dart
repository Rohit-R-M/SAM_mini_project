import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudScheduleScreen extends StatefulWidget {
  const StudScheduleScreen({super.key});

  @override
  State<StudScheduleScreen> createState() => _StudScheduleScreenState();
}

class _StudScheduleScreenState extends State<StudScheduleScreen> {
  String selectedDay = "Monday";
  Map<String, List<Map<String, String>>> timetable = {};
  String selectedSemester = "1";

  final List<String> weekDays = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ]; // Define the week days in order

  final List<String> semesters = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8"
  ]; // List of semesters

  @override
  void initState() {
    super.initState();
    fetchTimetable(); // Fetch timetable for the default semester
  }

  Future<void> fetchTimetable() async {
    try {
      // Clear existing timetable data before fetching new data
      timetable.clear();

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('timetable')
          .doc(selectedSemester)
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
      } else {
        // Show SnackBar if no timetable exists for the selected semester
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("TimeTable not added for this semester!")),
        );
      }
    } catch (e) {
      // Show error message in case of any exception
      print("Error fetching timetable: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching timetable. Please try again.")),
      );
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
            // Semester dropdown selection
            DropdownButtonFormField<String>(
              value: selectedSemester,
              decoration: InputDecoration(
                labelText: "Select Semester",
                labelStyle: TextStyle(
                  fontFamily: 'NexaBold',
                  fontWeight: FontWeight.w900,
                ),
              ),
              items: semesters.map((semester) {
                return DropdownMenuItem(
                  value: semester,
                  child: Text("Semester $semester",style: TextStyle(fontFamily: 'NexaBold',fontWeight: FontWeight.w900)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSemester = value!;
                  fetchTimetable();
                });
              },
            ),
            SizedBox(height: 10),


            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: weekDays.map((day) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = day;
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color:
                            selectedDay == day ? Colors.blue : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              selectedDay == day ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10),


            Expanded(
              child: RefreshIndicator(
                onRefresh:
                    fetchTimetable,
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
                          Map<String, String> subjectData =
                              timetable[selectedDay]![index];
                          String subject = subjectData['subject']!;
                          String time = subjectData['time']!;
                          return Card(
                            margin: EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(subject,style: TextStyle(fontFamily: 'Nexa'),),
                              subtitle: Text(time,style: TextStyle(fontFamily: 'NexaBold',fontWeight: FontWeight.w900),),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
