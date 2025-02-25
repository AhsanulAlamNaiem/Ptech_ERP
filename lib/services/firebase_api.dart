import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:ptech_erp/services/appResources.dart';
import 'package:ptech_erp/services/app_provider.dart';
import '../screens/home_screen.dart';
import 'database_helper.dart';

class FirebaseApi {
  final storage = FlutterSecureStorage();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // Request permissions for notifications
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    final designation = await storage.read(key: AppSecuredKey.designation);


    designation==AppDesignations.mechanic?
    await _firebaseMessaging.subscribeToTopic('mechanics'):
    _firebaseMessaging.unsubscribeFromTopic("mechanics");


    // Initialize local notifications for foreground handling
      _initializeLocalNotifications();
    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Message received in foreground: ${message.notification?.title}');
        await _storeNotification(message);
        _showNotification(
          message.notification?.title,
          message.notification?.body,
        );
    });

    // Handle background messages

      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);


    // Handle notification taps in Background  state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(" background: Notification clicked! Navigating...");
      handleNavigation();
    });

    // Handle notification taps in Terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("App launched from terminated state via notification");
        handleNavigation();
      }
    });
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _localNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async{
        print('user responded');
        handleNavigation();
        } );
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

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    await _storeNotification(message);
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Payload: ${message.data}');
  }

  static Future<void> _storeNotification(RemoteMessage message) async {
    await DatabaseHelper().insertNotification({
      'title': message.notification?.title ?? 'No Title',
      'body': message.notification?.body ?? 'No Content',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void handleNavigation() {
      print("will handle response");
      final context = AppNavigator.navigatorKey.currentContext;
      print(context);
      if(context!=null){
        print("have context");
        AppNavigator.navigatorKey.currentState?.popUntil((route)=>route.isFirst);
        context.read<AppProvider>().setIndex(2);
      } else {
        // If context is not available immediately, wait and retry
        Future.delayed(Duration(milliseconds: 500), () {
          final delayedContext = AppNavigator.navigatorKey.currentContext;
          if (delayedContext != null) {
            delayedContext.read<AppProvider>().setIndex(2);
          }
        });
      }
    }
  }


