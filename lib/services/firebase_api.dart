import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseApi {
  final storage = FlutterSecureStorage();
  final securedDesignation = "designation";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // Request permissions for notifications
    await _firebaseMessaging.requestPermission();

    // Get the FCM token
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');

    // Subscribe to a topic
    await _firebaseMessaging.subscribeToTopic('mechanics');

    final designation = await storage.read(key: securedDesignation);
    print("designation: $designation");

    // Handle background messages
    if(designation == "Mechanic"  || designation == "Admin Officer") {
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    }


    // Initialize local notifications for foreground handling

      _initializeLocalNotifications();

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received in foreground: ${message.notification?.title}');
      if(designation == "Mechanic"  || designation == "Admin Officer") {
        _showNotification(
          message.notification?.title,
          message.notification?.body,
        );
      }
    });
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _localNotificationsPlugin.initialize(initializationSettings);
  }

  void _showNotification(String? title, String? body) {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'main_channel', // Channel ID
      'Main Channel', // Channel Name
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    if (title != null || body != null) {
      _localNotificationsPlugin.show(
        0, // Notification ID
        title, // Notification title
        body, // Notification body
        platformDetails,
      );
    }
  }
}
