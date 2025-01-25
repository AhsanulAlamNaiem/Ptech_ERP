import 'package:flutter/material.dart';

class AppColors {
  static const Color mainColor = Color(0xFFEE1B22);
  static const Color accentColor = Color(0xFF42A5F5);
  static const Color fontColorBlack = Colors.black;
  static const Color fontColorGray = Color(0xFFDCDCDC);
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

  static const TextStyle bodyText = TextStyle(
  fontSize: 16.0,
  color: AppColors.textColorOnMainColor,
  );

  static const TextStyle buttonText = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.w500,
  color: AppColors.textColorOnMainColor,
  );

  // Button Styles
  static ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: AppColors.mainColor,
  textStyle: buttonText,
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(8.0)),
  ),
  ).copyWith(
  minimumSize: MaterialStateProperty.all(Size(double.infinity, 40)), // Set minimum width to full screen width
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

class securedKey {
  static const String token = 'b42b985d53c4';
  static const String name = '49431de06547';

  static const String designation = '49431de06547';
  static const String department = '5b6953794963';
  static const String company = '8ca7cec8fa1e';

  static const String userInfoObject = '940867e93788';
}


class AppApis{
  static const String login = 'https://machine-maintenance.ddns.net/api/user_management/login/';
  static const String employeeDetails = 'https://machine-maintenance.ddns.net/api/user_management/employee-details/';
  static const String BreakDownLogs = 'https://machine-maintenance.ddns.net/api/maintenance/breakdown-logs/';
  static const String Machines = 'https://machine-maintenance.ddns.net/api/maintenance/machines/';
  static const String getProblemCategory = 'https://machine-maintenance.ddns.net/api/maintenance/problem-category-type/';
}

class AppWidgets {
  Widget customAppBar(String title) {
    return PreferredSize(
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
                    Text(title, style: AppStyles.textOnMainColorheading,)
                  ]
              ),
              centerTitle: true,
            )));
  }
}