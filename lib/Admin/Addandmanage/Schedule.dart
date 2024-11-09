import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminManageSchedule extends StatefulWidget {
  const AdminManageSchedule({super.key});

  @override
  State<AdminManageSchedule> createState() => _AdminManageScheduleState();
}

class _AdminManageScheduleState extends State<AdminManageSchedule> {

  String? _selectedValue;

  final _formKey = GlobalKey<FormState>();
  String selectedDay = "Monday";
  Map<String, List<Map<String, String>>> timetable = {
    "Sunday": [],
    "Monday": [],
    "Tuesday": [],
    "Wednesday": [],
    "Thursday": [],
    "Friday": [],
    "Saturday": []
  };
  final _subjectController = TextEditingController();
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  int? editingIndex;

  final List<String> daysOfWeek = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];

  Future<void> pickStartTime(BuildContext context) async {
    if (selectedDay == "Sunday") return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        selectedStartTime = pickedTime;
      });
    }
  }

  Future<void> pickEndTime(BuildContext context) async {
    if (selectedDay == "Sunday") return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedStartTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null &&
        (selectedStartTime == null ||
            (pickedTime.hour > selectedStartTime!.hour ||
                (pickedTime.hour == selectedStartTime!.hour &&
                    pickedTime.minute > selectedStartTime!.minute)))) {
      setState(() {
        selectedEndTime = pickedTime;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("End time must be after start time"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return TimeOfDay.fromDateTime(dt).format(context);
  }

  void addOrUpdateSubjectWithTime() {
    if (_subjectController.text.isNotEmpty && selectedStartTime != null && selectedEndTime != null) {
      final formattedStartTime = formatTimeOfDay(selectedStartTime!);
      final formattedEndTime = formatTimeOfDay(selectedEndTime!);

      setState(() {
        if (editingIndex != null) {
          timetable[selectedDay]![editingIndex!] = {
            'subject': _subjectController.text.trim(),
            'time': '$formattedStartTime - $formattedEndTime',
          };
          editingIndex = null;
        } else {
          timetable[selectedDay]!.add({
            'subject': _subjectController.text.trim(),
            'time': '$formattedStartTime - $formattedEndTime',
          });
        }
        _subjectController.clear();
        selectedStartTime = null;
        selectedEndTime = null;
      });
    }
  }

  void editSubjectWithTime(int index) {
    setState(() {
      _subjectController.text = timetable[selectedDay]![index]['subject']!;
      final times = timetable[selectedDay]![index]['time']!.split(' - ');
      selectedStartTime = TimeOfDay(
        hour: int.parse(times[0].split(':')[0]),
        minute: int.parse(times[0].split(':')[1].split(' ')[0]),
      );
      selectedEndTime = TimeOfDay(
        hour: int.parse(times[1].split(':')[0]),
        minute: int.parse(times[1].split(':')[1].split(' ')[0]),
      );
      editingIndex = index;
    });
  }

  void deleteSubjectWithTime(int index) {
    setState(() {
      timetable[selectedDay]!.removeAt(index);
    });
  }

  Future<void> saveCompleteTimetable() async {
    try {
      await FirebaseFirestore.instance
          .collection('timetable')
          .doc(_selectedValue)
          .set(timetable);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Complete timetable saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        timetable = {
          "Sunday": [],
          "Monday": [],
          "Tuesday": [],
          "Wednesday": [],
          "Thursday": [],
          "Friday": [],
          "Saturday": []
        };
      });
    } catch (e) {
      print("Error saving data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving timetable.")),
      );
    }
  }

  Future<void> deleteTimetable() async {
    try {
      await FirebaseFirestore.instance
          .collection('timetable')
          .doc('weekdays')
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Timetable deleted successfully!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
        timetable = {
          "Sunday": [],
          "Monday": [],
          "Tuesday": [],
          "Wednesday": [],
          "Thursday": [],
          "Friday": [],
          "Saturday": []
        };
      });
    } catch (e) {
      print("Error deleting timetable: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting timetable.")),
      );
    }
  }

  Future<void> loadTimetable() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('timetable')
          .doc('weekdays')
          .get();

      if (docSnapshot.exists) {
        setState(() {
          timetable = docSnapshot.data()!.map((day, subjects) =>
              MapEntry(day, List<Map<String, String>>.from(subjects)));
        });
      } else {
        setState(() {
          timetable = {
            "Sunday": [],
            "Monday": [],
            "Tuesday": [],
            "Wednesday": [],
            "Thursday": [],
            "Friday": [],
            "Saturday": []
          };
        });
      }
    } catch (e) {
      print("Error loading timetable: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadTimetable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        title: Text("Manage Schedule",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Nexa',
                color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select an Semester',
                  labelStyle: TextStyle( fontFamily: 'NexaBold',fontWeight: FontWeight.w900),
                  border: UnderlineInputBorder(),
                ),
                value: _selectedValue,
                items: ['1', '2', '3', '4', '5', '6', '7', '8']
                    .map((String option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedValue = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select the Semester' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedDay,
                decoration: InputDecoration(labelText: "Select Day", labelStyle: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900)),
                onChanged: (value) {
                  setState(() {
                    selectedDay = value!;
                  });
                },
                items: daysOfWeek.map((day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
              ),
              if (selectedDay != "Sunday") ...[
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(labelText: "Enter Subject", labelStyle: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900)),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => pickStartTime(context),
                      child: Text(selectedStartTime == null
                          ? "Pick Start Time"
                          : "Start: ${formatTimeOfDay(selectedStartTime!)}",
                          style: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900)),
                    ),
                    ElevatedButton(
                      onPressed: () => pickEndTime(context),
                      child: Text(selectedEndTime == null
                          ? "Pick End Time"
                          : "End: ${formatTimeOfDay(selectedEndTime!)}",
                          style: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addOrUpdateSubjectWithTime,
                  child: Text(editingIndex != null ? "Update Schedule" : "Add Schedule",
                      style: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900)),
                ),
              ],
              SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: timetable[selectedDay]?.length ?? 0,
                  itemBuilder: (context, index) {
                    final item = timetable[selectedDay]![index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text("${item['subject']}", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${item['time']}"),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () => editSubjectWithTime(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => deleteSubjectWithTime(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: saveCompleteTimetable,
                    child: Text("Save Timetable", style: TextStyle(color: Colors.green, fontFamily: 'NexaBold',fontWeight: FontWeight.w900)),
                  ),

                  ElevatedButton(
                    onPressed: deleteTimetable,
                    child: Text("Delete Timetable", style: TextStyle(color: Colors.red, fontFamily: 'NexaBold',fontWeight: FontWeight.w900)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
