import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sam_pro/Notice.dart';
import 'package:sam_pro/Student/Academics/attendance.dart';
import 'package:sam_pro/Student/Academics/calendar.dart';
import 'package:sam_pro/Student/Academics/exam.dart';
import 'package:sam_pro/Student/Academics/result.dart';
import 'package:sam_pro/Student/drawer/Profile_View.dart';
import 'package:sam_pro/Student/drawer/Teacher_list.dart';
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

  @override
  void initState() {
    super.initState();
    loadUserProfile();
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
              child: const Text('Cancel'),
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
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: _imageUrl != null
                        ? NetworkImage(_imageUrl!)
                        : null,
                    child: _imageUrl == null
                        ? Icon(Icons.person,
                        size: 70, color: Colors.white)
                        : null,
                    backgroundColor: Colors.blueAccent[300],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _name ?? "User Name",
                    style: TextStyle(
                        fontSize: 20, color: Colors.white, fontFamily: 'Nexa'),
                  ),
                  Text(
                    _email ?? "user@example.com",
                    style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'NexaBold',
                        fontWeight: FontWeight.w600),
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
                  MaterialPageRoute(builder: (context) => TeacherList()),
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
            Divider(),
            ListTile(
              leading: const Icon(Icons.support_agent, color: Colors.orange),
              title: const Text(
                'Support',
                style: TextStyle(
                    fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
              onTap: () {

              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.red),
              title: const Text(
                'Report Bug',
                style: TextStyle(
                    fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
              onTap: () {

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
                height: 120,
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
                child: SingleChildScrollView(
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
                    title: Text(
                      _name ?? "Name not available",
                      style: TextStyle(
                          fontSize: 20, color: Colors.white, fontFamily: 'Nexa'),
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("ID: ",style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'NexaBold',
                            fontWeight: FontWeight.w900),
                        ),
                        Text(
                          _id ?? "ID not available",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'NexaBold',
                              fontWeight: FontWeight.w900),
                        ),
                        SizedBox(width: 30,),
                        Text("Sem: ",style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'NexaBold',
                            fontWeight: FontWeight.w900),
                        ),
                        Text(
                          _sem ?? "semester",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'NexaBold',
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 20,),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => calenderscreen(),
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              side: BorderSide(
                                  color: Colors.blueAccent, width: 2)),
                          child: Column(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.calendarCheck,
                                color: Colors.black,
                              ),
                              Text(
                                "Calendar",
                                style: TextStyle(
                                  fontFamily: 'NexaBold',
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => attendancescreen(),
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              side: BorderSide(
                                  color: Colors.blueAccent, width: 2)),
                          child: Column(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.personChalkboard,
                                color: Colors.black,
                              ),
                              Text(
                                "Attendance",
                                style: TextStyle(
                                  fontFamily: 'NexaBold',
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => resultscreen(),
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              side: BorderSide(
                                  color: Colors.blueAccent, width: 2)),
                          child: Column(
                            children: [
                              Icon(
                                Icons.auto_graph_outlined,
                                color: Colors.black,
                              ),
                              Text(
                                "Result",
                                style: TextStyle(
                                  fontFamily: 'NexaBold',
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => examscreen(),
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              side: BorderSide(
                                  color: Colors.blueAccent, width: 2)),
                          child: Column(
                            children: [
                              Icon(
                                Icons.grade,
                                color: Colors.black,
                              ),
                              Text(
                                "Exam",
                                style: TextStyle(
                                  fontFamily: 'NexaBold',
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoticeScreen(),
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              side: BorderSide(
                                  color: Colors.blueAccent, width: 2)),
                          child: Column(
                            children: [
                              Icon(
                                Icons.note,
                                color: Colors.black,
                              ),
                              Text(
                                "Notice",
                                style: TextStyle(
                                  fontFamily: 'NexaBold',
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(),
                                  ));
                            },
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                side: BorderSide(
                                    color: Colors.blueAccent, width: 2)),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.black,
                                ),
                                Text(
                                  "Profile",
                                  style: TextStyle(
                                    fontFamily: 'NexaBold',
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ))
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueAccent, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Course Name $index",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.blueAccent,
                                fontFamily: 'Nexa',
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Course Instructor $index",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontFamily: 'NexaBold',
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
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
