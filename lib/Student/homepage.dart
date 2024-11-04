import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sam_pro/Notice.dart';
import 'package:sam_pro/Student/Academics.dart';
import 'package:sam_pro/Student/drawer/Profile_View.dart';
import 'package:sam_pro/Student/drawer/Teacher_list.dart';
import 'package:sam_pro/Student/profile.dart';
import 'package:sam_pro/Student/notification.dart';
import 'package:sam_pro/Student/drawer/Student_list.dart';
import 'package:sam_pro/rolescreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const AcademicsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          // Main content with IndexedStack
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 5,
                    offset: Offset(0, 5), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(20))
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_today_rounded),
                      label: 'Academics',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout',style: TextStyle(fontFamily: 'Nexa',),),
          content: const Text('Are you sure you want to logout?',style: TextStyle(fontFamily: 'NexaBold',fontWeight: FontWeight.w900),),
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
              child: const Text('Logout',style: TextStyle(fontFamily: 'NexaBold',fontWeight: FontWeight.w900),),
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
        automaticallyImplyLeading: true,
        title: const Text(
          "Home",
          style: TextStyle(fontSize: 25,fontFamily: "Nexa"),
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
            icon: const Icon(Icons.notifications),
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
                  const Text(
                    "User Name",
                    style: TextStyle(fontSize: 20, color: Colors.white,fontFamily: 'Nexa'),
                  ),
                  const Text(
                    "user@example.com",
                    style: TextStyle(color: Colors.white70,fontFamily: 'NexaBold',fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Students List',style: TextStyle(fontFamily: 'NexaBold',fontWeight: FontWeight.w900),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentsList()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text('Teaching Staff',style: TextStyle(fontFamily: 'NexaBold',fontWeight: FontWeight.w900),),
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
              title: const Text('Profile Settings',style: TextStyle(fontFamily: 'NexaBold',fontWeight: FontWeight.w900),),
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
              title: const Text('Support',style: TextStyle(fontFamily: 'NexaBold',fontWeight: FontWeight.w900),),
              onTap: () {

              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.red),
              title: const Text('Report Bug',style: TextStyle(fontFamily: 'NexaBold',fontWeight: FontWeight.w900),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentsList()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout',style: TextStyle(fontFamily: 'NexaBold',fontWeight: FontWeight.w900),),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Divider(thickness: 2, indent: 20, endIndent: 20),
            Container(
              height: 150,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blueAccent,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/teacher_profile.jpg'),
                  backgroundColor: Colors.white,
                ),
                title: const Text(
                  "Name",
                  style: TextStyle(fontSize: 20, color: Colors.white,fontFamily: 'Nexa'),
                ),
                subtitle: const Text(
                  "ID",
                  style: TextStyle(fontSize: 16, color: Colors.white70,fontFamily: 'NexaBold',fontWeight: FontWeight.w600),
                ),
              ),
            ),

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
                                fontFamily: 'NexaBold',fontWeight: FontWeight.w600
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.note_add, color: Colors.blue),
              title: const Text(
                "Notice",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'Nexa',),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NoticeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
