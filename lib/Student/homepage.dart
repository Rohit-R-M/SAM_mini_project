import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sam_pro/Notice.dart';
import 'package:sam_pro/Student/Academics/Results/result.dart';
import 'package:sam_pro/Student/Academics/attendance.dart';
import 'package:sam_pro/Student/Academics/calendar.dart';
import 'package:sam_pro/Student/Academics/exam.dart';
import 'package:sam_pro/Student/View%20Notes/checkoutnotes.dart';
import 'package:sam_pro/Student/achievement.dart';
import 'package:sam_pro/Student/drawer/Profile_View.dart';
import 'package:sam_pro/Student/drawer/StudentSchedule.dart';
import 'package:sam_pro/Student/drawer/Teacher_list.dart';
import 'package:sam_pro/Student/drawer/addachivements.dart';
import 'package:sam_pro/Student/profile.dart';
import 'package:sam_pro/Student/notification.dart';
import 'package:sam_pro/Student/drawer/Student_list.dart';
import 'package:sam_pro/rolescreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _name;
  String? _id;
  String? _imageUrl;
  String? _email;
  String? _sem;
  String? _branch;
  String? _course_name;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<List<Map<String, dynamic>>> fetchCoursesBySemester() async {
    QuerySnapshot snapshot = await _firestore
        .collection('Admin_added_Course')
        .where('semester', isEqualTo: _sem)
        .where('branch', isEqualTo: _branch)
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot snapshot =
        await _firestore.collection('Student_users').doc(user.uid).get();
        if (snapshot.exists) {
          setState(() {
            final data = snapshot.data() as Map<String, dynamic>;
            _name = data['name'];
            _id = data['id'];
            _imageUrl = data['image_url'];
            _email = data['email'];
            _sem = data['semester'];
            _branch = data['branch_name'];
          });
        } else {
          print("User document does not exist.");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    } else {
      print("User is not authenticated.");
    }
  }

  // Function to manually refresh user profile data
  Future<void> _refreshUserProfile() async {
    await loadUserProfile();
  }

  void _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(
              fontFamily: 'Nexa',
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style:
            TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                    fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Rolescreen()),
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                    fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Home",
          style:
          TextStyle(fontSize: 25, fontFamily: "Nexa", color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => notificationscreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.blue, size: 40),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _name ?? "User Name",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: 'Nexa'),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _email ?? "user@example.com",
                      style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'NexaBold',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text(
                'Students List',
                style: TextStyle(
                    fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentsList()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text(
                'Teaching Staff',
                style: TextStyle(
                    fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FacultyListView()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text(
                'Profile Settings',
                style: TextStyle(
                    fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileViewScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                FontAwesomeIcons.add,
                color: Colors.blueAccent,
              ),
              title: const Text(
                'Add Achivements',
                style: TextStyle(
                    fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddAchievements(
                    id: _id?? "Unknown ID", semester: _sem??'Unknown Sem',
                  )),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.purple),
              title: const Text(
                'Schedules',
                style: TextStyle(
                    fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudScheduleScreen(),
                    ));
              },
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                    fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUserProfile,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 130,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blueAccent,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.grey,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: SizedBox(
                    width: 60, // Adjust width
                    height: 60, // Adjust height to keep it circular
                    child: CircleAvatar(
                      backgroundImage:
                      _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                      child: _imageUrl == null
                          ? Icon(Icons.person, color: Colors.white, size: 30)
                          : null,
                    ),
                  ),
                  title: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _name ?? "Name not available",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: 'Nexa'),
                    ),
                  ),
                  subtitle: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              _id ?? "ID not available",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'NexaBold',
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              _branch ?? "Branch not mentioned",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'NexaBold',
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIconButton(
                          context,
                          "Calendar",
                          Icons.calendar_today_outlined,
                          Colors.blue.shade50,
                          Colors.blueAccent,
                          calenderscreen()),
                      _buildIconButton(
                          context,
                          "Attendance",
                          Icons.person_pin_circle,
                          Colors.purple.shade50,
                          Colors.purpleAccent,
                          AttendanceScreen()),
                      _buildIconButton(
                          context,
                          "Result",
                          Icons.auto_graph,
                          Colors.green.shade50,
                          Colors.greenAccent,
                          ResultScreen(
                            name: _name??"",
                            id: _id??"",
                            semester: _sem??"",
                            course: _course_name??"",
                          )),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        margin: EdgeInsets.all(10),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewAchievements(
                                      id: _id?? "Unknown ID", semester: _sem??'Unknown Sem',
                                    )));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.trophy,
                                  size: 40, color: Colors.pinkAccent),
                              SizedBox(height: 8),
                              Text(
                                "COA",
                                style: TextStyle(
                                    fontFamily: 'NexaBold',
                                    fontWeight: FontWeight.w900),
                              )
                            ],
                          ),
                        ),
                      ),
                      _buildIconButton(
                          context,
                          "Notice",
                          Icons.note,
                          Colors.yellow.shade50,
                          Colors.yellowAccent,
                          NoticeScreen()),
                      _buildIconButton(
                          context,
                          "Profile",
                          Icons.person,
                          Colors.orange.shade50,
                          Colors.orangeAccent,
                          ProfileScreen()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 350, // Adjust the multiplier as needed
                child: FutureBuilder(
                  future: fetchCoursesBySemester(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No courses found.'));
                    }

                    List<Map<String, dynamic>> courses =
                    snapshot.data as List<Map<String, dynamic>>;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.separated(
                        itemCount: courses.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map<String, dynamic> course = courses[index];
                          return Container(
                            color: Colors.blue[50],
                            child: ListTile(
                              title: Text(
                                course['course_name'] ?? 'Unnamed Course',
                                style: TextStyle(fontFamily: 'Nexa'),
                              ),
                              subtitle: Text(
                                course['course_instructor'] ?? 'Course Instructor',
                                style: TextStyle(
                                    fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewNotesScreen(
                                          courseName: course['course_name']),
                                    ));
                              },
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            color: Colors.blue[200],
                            thickness: 1.0,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildIconButton(BuildContext context, String label, IconData icon,
    Color bgColor, Color iconColor, Widget targetPage) {
  return Container(
    margin: EdgeInsets.all(10),
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => targetPage));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: iconColor),
          SizedBox(height: 8),
          Text(
            label,
            style:
            TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
          )
        ],
      ),
    ),
  );
}