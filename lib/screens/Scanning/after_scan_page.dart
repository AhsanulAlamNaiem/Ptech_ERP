import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ptech_erp/services/app_provider.dart';

import '../../services/appResources.dart';
import 'after_scan_interactions.dart';
import 'machine_details.dart';

class AfterScanPage extends StatefulWidget {
  @override
  _AfterScanPageState createState() => _AfterScanPageState();
}

class _AfterScanPageState extends State<AfterScanPage> {
  bool isPatching = false;
  int selectedCategoryIndex = -1;
  String? selectedCategory;
  List<dynamic> problemCategories = [];

  int selectedSubCategoryIndex = -1;
  dynamic selectedSubCategory;
  List<dynamic> subCategories = [];
  dynamic strSelectedSubCategory;

  bool isFetchingProblemCategory = true;
  String? successMessage;

  String? questionText;
  String? status;

  Future<String?> getDesignation() async {
    final storage = FlutterSecureStorage();
    final designation = await storage.read(key: AppSecuredKey.designation);
    return designation;
  }

  void onCategoryChange(int categoryId) {
    setState(() {
      subCategories = problemCategories[categoryId - 1]['categories'];
      print("Selected Subcategories: $subCategories");
      selectedSubCategory = null; // Reset subcategory selection
    });
  }

  @override
  void initState() {
    super.initState();
    Provider.of<AppProvider>(context, listen: false).loadMachineData();
    isFetchingProblemCategory = false;
  }


  @override
  Widget build(BuildContext context) {
    double halfScreenWidth = MediaQuery.of(context).size.width * 0.44;
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isPatching) {
          print("patching now");
          return Center(child: CircularProgressIndicator());
        } else {
          if(appProvider.machine!=null){
              return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 5,
                      child: MachineDetailsPage()
                  ),

                  Expanded(
                      flex: 5,
                      child: AfterScanInteractionsPage()
                  )
                ],
              ),
            );
          } else{
            return Center(child: Column(children: [
              Spacer(),
              Text("No Data Found",style: AppStyles.textH2,),
              Spacer(),
              SizedBox(
                  width: halfScreenWidth-halfScreenWidth*0.05, // Set button width to 50% of screen
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    ),
                    onPressed: () {
                      context.read<AppProvider>().updateScannerState(scanningState: true);
                    }, child: Text("Scan Again",  style: AppStyles.buttonText,),
                  )),
              SizedBox(height: 15,)
            ]));
          }

        }
      },
    );
  }
}

Future<Map?> funcFetchMachineDetails(String model) async {
  final queryParams = {
    'machine_id': '$model'
  };
  final url = Uri.parse(AppApis.Machines).replace(queryParameters: queryParams);
  print(url);

  final headers = {'Content-Type': 'application/json'};
  final response = await http.get(url);

  print(response.statusCode);

  if (response.statusCode == 200) {
    List<dynamic> jsonDecodedData = jsonDecode(response.body);
    print("Json data: $jsonDecodedData");
    Map machineObject = jsonDecodedData[0];
    print("machine Object: $machineObject");
    return machineObject;
  }
}
