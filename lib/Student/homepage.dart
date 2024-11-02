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
  int _currentIndex = 0; // Track the selected tab

  // List of pages to display
  final List<Widget> _pages = [
    const HomePage(),
    const AcademicsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:
      IndexedStack(
        index: _currentIndex, // Display the selected page
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Highlight the selected tab
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update selected tab
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
    );
  }
}

// Home Page
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
            title: Text('Logout'),
            content: Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Cancel'),
              ),

              ElevatedButton(
                onPressed: () async {
                  await _auth.signOut(); // Sign out the user
                  Navigator.pop(context); // Close the dialog
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Rolescreen()),
                  ); // Navigate to login page
                },
                child: Text('Logout'),
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
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
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
             child: Text("Name",style: TextStyle(fontSize: 25,color: Colors.white),),
            ),

            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Profile Settings'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileViewScreen(),));
              },
            ),

            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text('Teaching Staff'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherList(),));
              },
            ),

            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Students List'),
              onTap: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => StudentsList()),);
              },
            ),

            ListTile(
              leading: const Icon(Icons.support_agent, color: Colors.orange),
              title: const Text('Support'),
              onTap: () {},
            ),



            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),


      body: Column(
        children: [

          Divider(
            thickness: 3,
            endIndent: 10,
            indent: 10,
          ),

          Container(
            height: 150,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.only(top: 30),
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
              leading: CircleAvatar(radius: 50),
              title: Text(
                "hello",
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
              subtitle: Text(
                "hi",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),

          SizedBox(height: 10,),

      SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Horizontal scrolling enabled.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) => Container(
              width: 220,
              height: 150,
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blueAccent,
                  width: 2,
                ),
              ),
              child: ListTile(
                title: Text(
                  "Course Name $index",

                ),
                subtitle: Text(
                  "Course Instructor $index",

                ),
              ),
            ),
          ),
        ),
      ),
          SizedBox(height: 20,),
          
          Column(
            children: [
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NoticeScreen(),));
                },
                child: ListTile(
                  leading: Icon(Icons.note_add),
                    title:  Text("Notice",style: TextStyle(fontSize: 20),),
                  trailing: Icon(Icons.arrow_forward),
                ),
              ),
              

            ],
          )
      ],
      ),
    );
  }
}
