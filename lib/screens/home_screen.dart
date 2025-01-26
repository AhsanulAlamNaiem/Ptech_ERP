import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ptech_erp/appResources.dart';
import 'package:ptech_erp/login_page.dart';
import 'package:ptech_erp/screens/inventory.dart';
import 'package:ptech_erp/screens/production.dart';
import 'machine_scanner.dart';
import 'maintainance.dart';

class HomeScreen extends StatefulWidget {
  Map user;
  HomeScreen({super.key, required this.user});

  @override
  _HomeScreenState createState() {
    return _HomeScreenState(user);
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final Map user;
  _HomeScreenState(this.user);
  final storage = FlutterSecureStorage();
  final securedKey = "Token";

  Future<Map> falsefetchUser() async {
    return Future.delayed(Duration(seconds: 5), () {
      return {"user": "falseUser"};
    });
  }

  @override
  Widget build(BuildContext context) {
    // return Text("$user");
    return homeScreenBuilder(user);
  }

  Widget homeScreenBuilder(Map user) {
    Widget funcHomeBuilder() {
      return Padding(
          padding: EdgeInsets.fromLTRB(16, 30, 16, 3),
        child:  Column(children: [
          Btn("Production", ProductionPage()),
          Btn("Maintenance", Maintanance()),
          Btn("Inventory", InventoryPage()),
          // ElevatedButton(
          //     onPressed: () async {
          //       final securedDesignation = "designation";
          //       final desg = await storage.read(key: securedDesignation);
          //       if (desg == "Mechanic") {
          //         await storage.write(
          //             key: securedDesignation, value: "Supervisor");
          //       } else {
          //         await storage.write(
          //             key: securedDesignation, value: "Mechanic");
          //       }
          //     },
          //     child: Text("change designation"))
        ]));
    }

    final List<Widget> pages = [
      // funcHomeBuilder(),
      funcHomeBuilder(),
      MachineScanner()
    ];

    return WillPopScope(
        onWillPop: () async {
          final shouldAllowPop = _currentIndex == 1 ? true : false;
          setState(() {
            _currentIndex = 0;
          });
          return shouldAllowPop; // Block back navigation
        },
        child: Scaffold(
          appBar: customAppBar(title: "Ptech ERP", action: [
            IconButton(
                onPressed: () async {
            // Handle sign out action
            await storage.delete(key: securedKey);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => LogInPage()));
          }, icon: Icon(Icons.logout))]),
          bottomNavigationBar: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(0),
            ),
            child: BottomNavigationBar(
            backgroundColor: AppColors.mainColor,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            showSelectedLabels: true,


            currentIndex: _currentIndex,

            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              // BottomNavigationBarItem(
              //     icon: Icon(Icons.dashboard), label: "Dashboard"),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.document_scanner), label: "Machine"),
            ],
          )),
          body: pages[_currentIndex],
          drawer: Drawer(
            child: SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50,),
                    Container(
                      color: AppColors.disabledMainColor,
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(backgroundImage: AssetImage("assets/images/user.png"), radius: 60, backgroundColor: AppColors.accentColor,),
                        SizedBox(height: 15),
                        Text("${user["name"]}",style: AppStyles.textH2,),
                        Text("${user["designation"]}, ${user["department"]}"),
                        Text("${user["company"]}",style: AppStyles.textH3,),
                        SizedBox(height: 15),
                        Divider(
                          color: AppColors.accentColor,      // Color of the line
                          thickness: 4.0,          // Thickness of the line
                          indent: 0.0,            // Start padding
                          endIndent: 0.0,         // End padding
                        ),
                      ]
                    )),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        TextButton(onPressed: (){}, child: Text("Terms & Conditions")),
                        TextButton(onPressed: (){}, child: Text("Contact Us")),
                        TextButton(onPressed: (){}, child: Text("Help/FAQs")),
                        TextButton(onPressed: (){}, child: Text("Subscriptions")),
                        TextButton(onPressed: (){}, child: Text("Rate Us")),
                        TextButton(onPressed: (){}, child: Text("Update")),
                      ]
                    ),

                    Spacer(),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/panaceaLogo.png',
                                width: 60, height: 60,fit: BoxFit.cover),
                            Text('Ptech ERP - Panacea Private Consultancy', style: AppStyles.bodyTextgray,),
                          ],
                        ),
                      )
                      ]
                    ),
                  ],
                )),
          ),
        ));
  }
}

class Btn extends StatelessWidget {
  final String title;
  final Widget screen;
  const Btn(this.title, this.screen, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(0,10,0,10), // Add margin around the button
    child: ElevatedButton(
        style: AppStyles.homePageBUttonStyle,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => screen));
        },
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.mainColor, // White background for the icon
                  shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10)
                ),
                padding: EdgeInsets.all(7),
                child: Icon(Icons.stacked_bar_chart_outlined,
                    color: Colors.white,
                size:40),
              ),
              SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                    color: Colors.black, // Text color
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ))
            ]
        )
        ]
        )
    ));
  }
}
