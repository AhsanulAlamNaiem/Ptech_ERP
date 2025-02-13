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

  String? status;
  Map machine = {};
  double? halfScreenWidth;


  @override
  void initState() {
    super.initState();
    isFetchingProblemCategory = false;
    isPatching=false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(title: "Machine", leading: IconButton(onPressed: (){
          Navigator.pop(context);
          Provider.of<AppProvider>(context, listen: false).setIndex(0);
          },
            icon: Icon(Icons.arrow_back))),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child:  SingleChildScrollView(
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IconButton(onPressed: ()=>_refreshData(), icon: Icon(Icons.refresh)),
                  Container(
                    child: MachineDetailsPage(),
                  ),
                  Container(
                      child: AfterScanInteractionsPage()
                    // child: TextField(),
                  ),
                  // Container(child: TextField())
                ],
              )),
        ));
  }


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
}



