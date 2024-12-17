import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  FirebaseMessaging message = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';

  // Initialize local notifications
  Future<void> initLocalNotification(RemoteMessage message) async {
    var androidInitializationSettings =
    const AndroidInitializationSettings('@mipmap/launcher_icon');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
        // Handle notification click event
      },
    );
  }

  // Firebase notification listener
  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      print('Notification Received: ${message.notification?.title}');
      print('Notification Body: ${message.notification?.body}');
      showNotification(message);
    });
  }

  // Show local notification
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      importance: Importance.max,
    );

    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: "Your channel description",
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    if (message.notification != null) {
      _flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title ?? 'No Title',
        message.notification!.body ?? 'No Body',
        notificationDetails,
      );
    }
  }

  // Request notification permissions
  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await message.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print("User granted provisional permission");
    } else {
      print("User denied permission");
    }
  }

  // Get device token
  Future<String> getDeviceToken() async {
    String? token = await message.getToken();
    return token ?? '';
  }
}
