import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppColors {
  static const Color mainColor = Color(0xFFEE1B22);
  static const Color accentColor = Color(0x88EE1B22);
  static const Color fontColorBlack = Colors.black;
  static const Color fontColorGray = Color(0xFF5555555);
  static const Color disabledMainColor = Color(0xFFFFE8E8);
  static const Color textColorOnMainColor = Color(0xFFFFFFFF);

}

class AppFonts {
  static const Color mainColor = Color(0xFFDCDCDC);
  static const Color accentColor = Color(0xFF42A5F5);
  static const Color fontColorBlack = Colors.black;
  static const Color fontColorGray = Colors.grey;
  static const Color disabledMainColor = Color(0xFFBDBDBD);
}

class AppStyles {
  // Text Styles
  static const TextStyle textOnMainColorheading = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.bold,
  color: AppColors.textColorOnMainColor,
  );

  static const TextStyle textH2 = TextStyle(
  fontSize: 16.0,
  color: Colors.black,
    fontWeight: FontWeight.bold
  );
  static const TextStyle textH3 = TextStyle(
      fontSize: 14.0,
      color: Colors.black,
      fontWeight: FontWeight.bold
  );
  static const TextStyle textH4 = TextStyle(
      fontSize: 12.0,
      color: Colors.black,
      fontWeight: FontWeight.bold
  );

  static const TextStyle bodyText = TextStyle(
      fontSize: 11.0,
      color: Colors.black,
      fontWeight: FontWeight.normal
  );

  static const TextStyle bodyTextgray = TextStyle(
      fontSize: 11.0,
      color: AppColors.fontColorGray,
      fontWeight: FontWeight.normal
  );

  static const TextStyle bodyTextBold = TextStyle(
      fontSize: 11.0,
      color: Colors.black,
      fontWeight: FontWeight.bold
  );

  static const TextStyle buttonText = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.w500,
  color: AppColors.textColorOnMainColor,
  );

  static ButtonStyle  textButtonWhite = TextButton.styleFrom(
    textStyle: textH4
  );

  // Button Styles
  static ButtonStyle elevatedButtonStyleFullWidth = ElevatedButton.styleFrom(
  backgroundColor: AppColors.mainColor,
  textStyle: buttonText,
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(8.0)),
  ),
  ).copyWith(
  minimumSize: MaterialStateProperty.all(Size(double.infinity, 40)), // Set minimum width to full screen width
  );

  static ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.mainColor,
    textStyle: buttonText,
  );


  static ButtonStyle homePageBUttonStyle = ElevatedButton.styleFrom(
    textStyle: buttonText,
    backgroundColor: Colors.white, // Button background color
    shadowColor: Colors.grey.withOpacity(0.4), // Light ash shadow
    elevation: 6, // Shadow elevation
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
    ),
  ).copyWith(
    minimumSize: MaterialStateProperty.all(Size(double.infinity, 80)), // Set minimum width to full screen width
  );




  static  ButtonStyle textButtonStyle = ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsets>(
        EdgeInsets.all(0)),
  );

}

class AppSecuredKey {
  static const Object storage = FlutterSecureStorage();
  static const String authHeaders = 'b42b985d53c4';
  static const String name = '49431de06547';
  static const String id = '4943135dte54t';

  static const String designation = '4943143t40653x';
  static const String department = '5b6953794963';
  static const String company = '8ca7cec8fa1e';

  static const String userInfoObject = '940867e93788';
}

class AppDesignations{
  static const String mechanic = "Mechanic";
  static const String superVisor = "Supervisor";
}

class AppMachineStatus{
  static const String active = "active";
  static const String broken = "broken";
  static const String maintenance = "maintenance";
}




PreferredSize customAppBar({required String title, List<Widget>? action = null , Widget? leading = null}) {
  return PreferredSize(
      preferredSize: Size.fromHeight(50), // Adjust the height as needed
      child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15), // Bottom left corner rounded
            bottomRight: Radius.circular(15), // Bottom right corner rounded
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color:Colors.white),
            backgroundColor: AppColors.mainColor,
            title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // SizedBox(height: 20,),
                  Text(title, style: AppStyles.textOnMainColorheading,)
                ]
            ),
            centerTitle: true,
            leading: leading,
            actions: action,
          )));
}

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class User{
  final int id;
  final String name;
  final String designation;
  final String department;
  final String company;
  bool canRepair;
  bool canChangeToMaintenanceStage;
  bool willReceiveNotification;



  User({
    required this.id,
    required this.name,
    required this.designation,
    required this.company,
    required this.department,
    this.canRepair=false,
    this.canChangeToMaintenanceStage=false,
    this.willReceiveNotification=false,
});

  factory User.fromJson({required Map jsonObject}){
    return User(
        id: jsonObject["id"],
        name: jsonObject["name"],
        designation: jsonObject["designation"],
        company: jsonObject["company"],
      department: jsonObject["department"]
    );
  }

  Map<String, String> toJson(){
    Map<String, String> userJson= {
      "id": id.toString(),
      "name": name,
      "designation": designation,
      "company": company,
      "department": department,
    };
    return userJson;
  }
}
