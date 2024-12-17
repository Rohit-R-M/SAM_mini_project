import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sam_pro/splashscreen.dart';
import 'package:http/http.dart' as http;
import 'package:sam_pro/Notificationforall.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NotificationServices notificationServices = NotificationServices();
  String deviceToken = 'Fetching token...';

 void initState(){
    super.initState();
    notificationServices.requestNotificationPermission();


    Future.delayed(Duration(seconds: 5), () {
      notificationServices.getDeviceToken().then((value) {
        setState(() {
          deviceToken = value;
        });
        print("Device token: $deviceToken");
      }).catchError((e) {
        print("Error fetching device token: $e");
      });
    });

    notificationServices.firebaseInit();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
