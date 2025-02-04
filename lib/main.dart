import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ptech_erp/services/app_provider.dart';
import 'package:ptech_erp/services/firebase_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ptech_erp/screens/home_screen.dart';
import 'package:ptech_erp/login_page.dart';
import 'appResources.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await FirebaseApi().initNotifications();
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

  Future<Map?> loginControl() async {
    // final name =  "John Doe";
    // final designation = "admin";
    // final department = "Engineering";
    // final company = "Acme Corporation";

    // await storage.write(key: securedKey, value: "252534563456");
    // await storage.write(key: securedName, value: name);
    // await storage.write(key: securedDesignation, value: designation);
    // await storage.write(key: securedDepartment, value: department);
    // await storage.write(key: securedCompany, value: company);

    final token = await storage.read(key: AppSecuredKey.token);
    final namee = await storage.read(key: AppSecuredKey.name) ?? "null";
    final designatione = await storage.read(key: AppSecuredKey.designation) ?? "null";
    final departmente = await storage.read(key: AppSecuredKey.department) ?? "null";
    final companye = await storage.read(key: AppSecuredKey.company) ?? "null";

    final userInfo = {
      "name": namee,
      "designation": designatione,
      "department": departmente,
      "company": companye
    };
    print("token $token");
    if (token != null) {
      return userInfo;
    }
    return null;
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
                return Center(child: Column( children: [CircularProgressIndicator()]));
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
