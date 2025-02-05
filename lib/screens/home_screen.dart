import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:ptech_erp/services/appResources.dart';
import 'package:ptech_erp/login_page.dart';
import 'package:ptech_erp/screens/inventory.dart';
import 'package:ptech_erp/screens/production.dart';
import 'package:ptech_erp/services/app_provider.dart';
import 'package:ptech_erp/services/database_helper.dart';
import '../services/firebase_api.dart';
import 'machine_scanner.dart';
import 'maintainance/maintainance.dart';
import 'notification_page.dart';

class HomeScreen extends StatefulWidget {
  Map user;
  HomeScreen({super.key, required this.user});

  @override
  _HomeScreenState createState() {
    return _HomeScreenState(user);
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final Map user;
  _HomeScreenState(this.user);
  final storage = FlutterSecureStorage();

    Future<Map> falsefetchUser() async {
    return Future.delayed(Duration(seconds: 5), () {
      return {"user": "falseUser"};
    });
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = context.watch<AppProvider>().index;

    Widget funcHomeBuilder() {
      return Padding(
          padding: EdgeInsets.fromLTRB(16, 30, 16, 3),
        child:  Column(children: [
          Btn("Production", ProductionPage(), Icons.factory),
          Btn("Maintenance", Maintanance(), Icons.handyman),
          Btn("Inventory", InventoryPage(),Icons.assignment),
        ]));
    }

    final List<Widget> pages = [
      funcHomeBuilder(),
      MachineScanner(),
      NotificationsPage()
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
          appBar: customAppBar(
              title:  (_currentIndex==2)?"Notifications":"Ptech ERP",
              action: [ (_currentIndex==0)?
          IconButton(
                onPressed: () async {
            // Handle sign out action
            await storage.delete(key: AppSecuredKey.token);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => LogInPage()));
          }, icon: Icon(Icons.logout)):
              (_currentIndex==2)?

              IconButton(onPressed: () async{
                context.read<AppProvider>().deleteAllNotifications();
                final localNotifications = await DatabaseHelper().getNotifications();
                context.read<AppProvider>().loadNotification();

              }, icon: Icon(Icons.delete_sweep)):Text("")]),


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
              context.read<AppProvider>().updateScannerState(scanningState: true);
              setState(() {
                context.read<AppProvider>().setIndex(index);
              });

            },

            items: const [
              // BottomNavigationBarItem(
              //     icon: Icon(Icons.dashboard), label: "Dashboard"),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.document_scanner), label: "Machine"),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications")
            ],
          )),
          body: pages[_currentIndex],
          drawer: Container(
          width: MediaQuery.of(context).size.width * 0.85,
           child: Drawer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: AppColors.disabledMainColor,
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 50,),
                        Container(
                          width: 80, // Diameter = 2 * radius
                          height: 80,
                          decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mainColor,
                        image: DecorationImage(
                          image: AssetImage("assets/images/user.png"),
                          fit: BoxFit.fitHeight, // Ensures the image fits properly
                          ),
                        )),
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
                    Container( child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        TextButton(onPressed: (){}, child: Text("Terms & Conditions", style: AppStyles.textH3,)),
                        TextButton(onPressed: (){}, child: Text("Contact Us",  style: AppStyles.textH3)),
                        TextButton(onPressed: (){}, child: Text("Help/FAQs",  style: AppStyles.textH3)),
                        TextButton(onPressed: (){}, child: Text("Subscriptions",  style: AppStyles.textH3)),
                        TextButton(onPressed: (){}, child: Text("Rate Us",  style: AppStyles.textH3)),
                        TextButton(onPressed: (){}, child: Text("Update",  style: AppStyles.textH3)),
                      ]
                    )),

                    Spacer(),


                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container( child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/ppclogotransparent.png',
                                width: 50, height: 50,fit: BoxFit.cover),
                            Text('Ptech ERP - Panacea Private Consultancy', style: AppStyles.bodyTextgray,),
                            Text('Version 1.2.0', style: AppStyles.bodyTextgray,),
                            Divider(
                              color: Colors.transparent,      // Color of the line
                              thickness: 0.0,          // Thickness of the line
                              indent: 0.0,            // Start padding
                              endIndent: 0.0,         // End padding
                            )
                          ],
                        ),
                      )
                    ),
                  ],
                )),
          ),
        ));
  }
}

class Btn extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget screen;
  const Btn(this.title, this.screen, this.icon, {super.key});

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
                child: Icon(icon,
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
