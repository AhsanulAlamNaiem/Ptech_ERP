import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ptech_erp/services/api_services.dart';
import 'package:ptech_erp/services/app_provider.dart';
import 'package:ptech_erp/services/firebase_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ptech_erp/screens/home_screen.dart';
import 'package:ptech_erp/login_page.dart';
import 'package:ptech_erp/services/secreatResources.dart';
import 'services/appResources.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await FirebaseApi().initNotifications(willReceiveNotification: false);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context)=>AppProvider()
          )
      ],
    child: MaterialApp(
      navigatorKey: AppNavigator.navigatorKey,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    ));

  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SPlashScreenState createState() {
    return _SPlashScreenState();
  }
}

class _SPlashScreenState extends State<SplashScreen> {
  final storage = FlutterSecureStorage();
  String? designatione;

  Future<User?> loginControl() async {
    final token = await storage.read(key: AppSecuredKey.authHeaders);
    print("token: $token");

    if (token != null) {
      final employeUrl = Uri.parse(AppApis.employeeDetails);
      final  tokenJson = jsonDecode(token);

      final  Map<String,String> headers = {
        "cookie":tokenJson["cookie"].toString(),
        "Authorization":tokenJson["Authorization"].toString()
      };


      final user = await ApiService().fetchUserInfoFunction(authHeaders: headers);
      if(user!=null){
        final userWithAllInfo = await ApiService().fetchUserPermissions(authHeaders: headers, user: user);
        return userWithAllInfo;
      }

    }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(""),
        ),
        body: FutureBuilder(
          future: loginControl(),
          builder: (context, snapshot) {
            Future(() {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center (child:  CircularProgressIndicator());
              } else if (snapshot.hasData) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreen(
                              user: snapshot.data!,
                            )));
              } else {
                print(snapshot.data);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LogInPage()));
              }
            });
            return Center(
                child: Column(
              children: [CircularProgressIndicator()],
            ));
          },
        ));
  }
}
