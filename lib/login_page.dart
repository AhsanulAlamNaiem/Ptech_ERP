import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:ptech_erp/screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:ptech_erp/services/app_provider.dart';
import 'package:ptech_erp/services/firebase_api.dart';
import 'package:ptech_erp/services/secreatResources.dart';
import 'dart:convert';
import 'services/appResources.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  String email = "";
  String password = "";
  bool isLoading = false;
  final storage = FlutterSecureStorage();

  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true; // This controls password visibility

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse(AppApis.login);
    final body = jsonEncode({"email": email, "password": password});

    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(url, body: body, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      print("Response data: $token");
      final cookies = response.headers['set-cookie']!.split(";");
      final cookie = "${cookies[0]}; ${cookies[4].split(",")[1]}";

      if (token != null) {
        final employeUrl = Uri.parse(AppApis.employeeDetails);
        final headers = {"cookie": cookie, "Authorization": "Token $token"};

        print(headers);
        final response = await http.get(employeUrl, headers: headers);
        print(response.body);

        if (response.statusCode == 200) {
          Map employeeInfo = jsonDecode(response.body);

          await storage.write(
              key: AppSecuredKey.userInfoObject, value: jsonEncode(employeeInfo));

          await storage.write(key: AppSecuredKey.token, value: token);
          await storage.write(key: AppSecuredKey.name, value: employeeInfo["name"]);
          await storage.write(
              key: AppSecuredKey.designation, value: employeeInfo["designation"]);

          await storage.write(
              key: AppSecuredKey.department, value: employeeInfo["department"]);
          await storage.write(
              key: AppSecuredKey.company, value: employeeInfo["company"]);
          await storage.write(
              key: AppSecuredKey.id, value: employeeInfo['id'].toString());
          await FirebaseApi().initNotifications();


          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text("Login Successful"),
                    content: Text("Welcome, ${employeeInfo["name"]}"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                          user: employeeInfo,
                                        )));
                          },
                          child: Text("Ok"))
                    ],
                  ));
        } else {
          showError(
              'Failed Fetching User Info\n\n ${response.body} ${response.statusCode}');
          print(response.body);
        }
      } else {
        showError('Failed to Login');
      }
    } else {
      showError("${response.body}}");
    }
    setState(() {
      isLoading = false;
    });
  }

  void showError(String message) {
    showDialog(
        context: context,
        builder: (contex) => AlertDialog(
              title: Text('Error'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context), child: Text("Ok"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
        preferredSize: Size.fromHeight(80), // Adjust the height as needed
    child: ClipRRect(
    borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(15), // Bottom left corner rounded
    bottomRight: Radius.circular(15), // Bottom right corner rounded
    ),
    child: AppBar(

          backgroundColor: AppColors.mainColor,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
            SizedBox(height: 26.0),
            Text("Ptech ERP", style: AppStyles.textOnMainColorheading,)
          ]
          ),
          centerTitle: true,
        ))),
        body: SingleChildScrollView(child:  Padding(
          padding: const EdgeInsets.fromLTRB(16.0,40,16,0),
          child: Container(
              height: MediaQuery.of(context).size.height-165,
              child: Column( children: [ Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              TextFormField(
                autofillHints: [AutofillHints.email],
                // validator: (val)=> val!.isEmpty || !val.contains("@")?"enter a valid email":null,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                    hintText: 'Email',
                    border: OutlineInputBorder(),
                    labelText: "Email",
                ),
                onChanged: (value) {
                  email = value;
                },
              ),
              SizedBox(height: 20),
              TextField(
                autofillHints: [AutofillHints.password],
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(onPressed: (){
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });

                    }, icon: Icon(_obscurePassword? Icons.visibility:Icons.visibility_off)),
                    hintText: 'Password',
                    border: OutlineInputBorder(),
                    labelText: "Password",
                ),
                onChanged: (value) {
                  password = value;
                },
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    style: AppStyles.elevatedButtonStyleFullWidth,
                      onPressed: () {
                        login();
                      },
                      child: Text("Login", style: TextStyle(color: Colors.white),)),
              TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.all(0)),
                  ),
                  onPressed: (){}, child: Text("Forget Password?", style: TextStyle(color: Colors.black))),

              // ElevatedButton(
              //     style: AppStyles.elevatedButtonStyle,
              //     onPressed: () async {
              //       final value = await storage.read(key: securedKey);
              //       print("$securedKey : $value");
              //     },
              //     child: Text("read Secure data"))

            ],
          ),
            Spacer(),
            Image.asset('assets/images/panaceaLogo.png',
                width: 50, height: 50,fit: BoxFit.cover),
            Text("Ptech ERP - Panacea Private Consulting", style: TextStyle(color: AppColors.fontColorGray)),
            SizedBox(height: 10)])
        ))));
  }
}
