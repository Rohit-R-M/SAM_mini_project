import 'package:flutter/material.dart';
import 'package:sam_pro/Student/notification.dart';
import 'package:sam_pro/Teacher/Home/TeacherAttendence.dart';
import 'package:sam_pro/Teacher/Home/TeacherProfile.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    TeacherAttendanceScreen(),
    TeacherProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _pages[_currentIndex], // Show the currently selected page
      bottomNavigationBar: Container(
        height: 70,
        margin: EdgeInsets.only(left: 12, right: 12, bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 5,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index; // Update the current index
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_rounded),
                label: 'Attendance',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          "Teachers Home",
          style: TextStyle(fontFamily: 'Nexa'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => notificationscreen(), // Ensure this class is defined correctly
                ),
              );
            },
            icon: Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Teacher Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'NexaBold',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Manage your portal',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'NexaBold',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.group, color: Colors.orangeAccent),
              title: Text(
                "Faculty List",
                style: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
              onTap: () {
                // Implement navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.group, color: Colors.blueAccent),
              title: Text(
                "Student List",
                style: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
              onTap: () {
                // Implement navigation
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person, color: Colors.greenAccent),
              title: Text(
                'Profile Settings',
                style: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
              onTap: () {
                // Implement navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.grey),
              title: Text(
                'Settings',
                style: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
              onTap: () {
                // Implement navigation
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Logout',
                style: TextStyle(fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
              ),
              onTap: () {
                // Implement logout
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.blueAccent[100],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Name',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'Nexa',
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Subject Teacher',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontFamily: 'NexaBold',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Icon(Icons.email, color: Colors.black54, size: 18),
                              SizedBox(width: 5),
                              Text(
                                'Email',
                                style: TextStyle(color: Colors.black54, fontFamily: 'NexaBold', fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
