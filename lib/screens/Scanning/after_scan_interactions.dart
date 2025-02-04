import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ptech_erp/services/app_provider.dart';
import '../../appResources.dart';

class AfterScanInteractionsPage extends StatefulWidget {
  @override
  _AfterScanInteractionsPageState createState() => _AfterScanInteractionsPageState();
}

class _AfterScanInteractionsPageState extends State<AfterScanInteractionsPage> {
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

  Future<void> updateMachineStatus({
    required String lastProblem,
    required String status,
    required int problemIndex,
    Map breakdownBody = const {},
    bool willUpdateBreakdown = false}) async {

    final machine =  context.read<AppProvider>().machine!;

    final currentTIme = DateTime.now().toUtc().toString().split('.').first;

    Map body = {
      "status": status,
      "last_repairing_start": (status==AppMachineStatus.maintenance)? currentTIme.split(" ")[0] +"T" +currentTIme.split(" ")[1] +"Z": "${machine["last_repairing_start"]}",
      "last_breakdown_start": (status==AppMachineStatus.broken)?  currentTIme.split(" ")[0] +"T" +currentTIme.split(" ")[1] +"Z" :"${machine["last_breakdown_start"]}",
      "last_problem": "$lastProblem"
    };

    DateTime startTime = DateTime.parse("${machine['last_breakdown_start']}");
    DateTime endTime = DateTime.parse(DateTime.now().toUtc().toString().split('.').first +'Z');
    String formattedDuration = endTime.difference(startTime).toString().split('.').first;

    final breakdownBody = {
      "breakdown_start": "$startTime",
      "repairing_start": "${machine['last_repairing_start']}",
      "lost_time": formattedDuration,
      "comments": "",
      "machine": "${machine['id']}",
      "mechanic": "",
      "operator": "",
      "problem_category": "$problemIndex",
      "location": "1",
      "line": "${machine['line']}",
    };


    try {
      final url = Uri.parse(AppApis.Machines + "${machine["id"]}/");
      print(url);
      print("Status supposed to be updated to $body");
      final response = await http.patch(url,body: body);
      print( "${response.statusCode} ${response.body}");
      String successMessage = (response.statusCode==200)? "Status Updated": "Status not Updated";
      if (willUpdateBreakdown) {
        final patchResponse =
        await http.post(Uri.parse(AppApis.BreakDownLogs), body: breakdownBody);
        print(breakdownBody);
        print("Breakdown updated ${patchResponse.body}");
        // Show success message

        if(patchResponse.statusCode ==200){
          successMessage = successMessage + " and Breakdown log Added";
        } else if(response.statusCode!=200){
          successMessage = successMessage + " and Breakdown log NOT Added";
        }

      } else {
        print("will not Update breaddwonLodg");
      }

    } catch (e) {
      print("Error: $e");
      final successMessage = "An error occurred while updating status.";
    }
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

  @override
  void initState() {
    super.initState();
    print("initiated");
    fetchProblemCategories();
    print("fetched");
    isFetchingProblemCategory = false;
  }

  Future<void> fetchProblemCategories() async {
    try {
      final response = await http.get(Uri.parse(AppApis.getProblemCategory));
      if (response.statusCode == 200) {
        setState(() {
          problemCategories = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final machine = context.read<AppProvider>().machine!;
    double halfScreenWidth = MediaQuery.of(context).size.width * 0.44;

    return FutureBuilder(
      future: getDesignation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          final designation = snapshot.data ?? "Unknown";
          final machineStatus = machine['status'];

          if (designation == AppDesignations.superVisor) {
            if (machineStatus == AppMachineStatus.active) {
              status = "Broken";
              questionText =
              'Is the Machine Broken?\nif yes, at first select problem category and then press "Set to $status" Button';
            }
            else if (machineStatus == AppMachineStatus.maintenance) {
              status = "Active";
              questionText =
              'Is the Machine Active now?\nif yes, at first select problem category and then press "Set to $status" Button';
            }
          } else if (designation == AppDesignations.mechanic && machineStatus == AppMachineStatus.broken) {
            status = "Repair";
            questionText =
            'The Machine is Broken?\nTo set it in Maintenance stage press "Set to $status" Button';
          }


          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Card(

                  child: Container(
                      width: double.infinity,
                      child: Padding(padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              (status==null)?SizedBox(height: 0,): Text("$questionText!", style: AppStyles.textH3,),

                              Spacer(),
                              (status==null || designation ==AppDesignations.mechanic )? const SizedBox(height: 0):  problemCategories.isEmpty
                                  ? const CircularProgressIndicator()
                                  : Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10), // Rounded corners
                                    border: Border.all(color: AppColors.disabledMainColor, width: 1), // Border styling
                                  ),
                                  child: DropdownButton<String>(
                                    style: AppStyles.textH3 ,
                                    value: selectedCategory,
                                    hint: const Text("Select Problem Category"),
                                    isExpanded: true,
                                    items: problemCategories.map((category) {
                                      return DropdownMenuItem<String>(
                                        value: category['id'].toString(),
                                        child: Text(category['name']),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedCategory = newValue;
                                        selectedCategoryIndex = int.parse(newValue!);
                                      });
                                      onCategoryChange(selectedCategoryIndex);
                                    },
                                  )),

                              designation==AppDesignations.superVisor? const SizedBox(height: 5.0): const SizedBox(height: 0),
                              (status==null || designation ==AppDesignations.mechanic )? const SizedBox(height: 0) :Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10), // Rounded corners
                                    border: Border.all(color: AppColors.disabledMainColor, width: 1), // Border styling
                                  ),
                                  child: DropdownButton<String>(
                                    style: AppStyles.textH3,
                                    value: selectedSubCategory,
                                    hint: const Text("Select Problem Subcategory"),
                                    isExpanded: true,
                                    items: subCategories.map((subCategory) {
                                      return DropdownMenuItem<String>(
                                        value: subCategory['id'].toString(),
                                        child: Text(subCategory['name']),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedSubCategory = newValue;
                                        selectedSubCategoryIndex = int.parse(newValue!);
                                        strSelectedSubCategory = subCategories.firstWhere((item)=>item['id']==selectedSubCategoryIndex)['name'];
                                        print(strSelectedSubCategory);
                                      });
                                    },
                                  )),
                            ],
                          )
                      )
                  ),
                ),
              ),

              Expanded(
                flex: 1,
                child: Row(
                    mainAxisAlignment: (status==null) ? MainAxisAlignment.center :  MainAxisAlignment.spaceAround,
                    children: [
                     (status==null)? SizedBox(height: 0):
                      SizedBox(
                          width: halfScreenWidth + halfScreenWidth *0.035, // Set button width to 50% of screen
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                            ),
                            onPressed: () {
                              print("$machine \n${status}\n$strSelectedSubCategory\nwillupdatebreakdown: ${designation=='Supervisor' && status =='Active'}");
                              context.read<AppProvider>().updatePatchingState(true);
                              updateMachineStatus(
                                  status: status=='Repair'?"maintenance":status!.toLowerCase(),
                                  lastProblem: strSelectedSubCategory??"Null",
                                  problemIndex: selectedSubCategoryIndex,
                                  willUpdateBreakdown: designation==AppDesignations.superVisor && status=='Active',
                              );
                              context.read<AppProvider>().updatePatchingState(false);
                            }, child: Text("Set to ${status}", style: AppStyles.buttonText),
                          )),


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
                    ]
                ),
              )
              // SizedBox(height: 50),
              // Display based on conditions,
            ],
          );
        }
      },
    );
  }
}
// Function to update the machine status


Future<void> updateMachineStatus({
  required String lastProblem,
  required String status,
  required Map machine,
  required int problemIndex,

  Map breakdownBody = const {},
  bool willUpdateBreakdown = false,
  required Function patchRequestStateUpdater}) async {

  patchRequestStateUpdater(patchingState:true);

  final currentTIme = DateTime.now().toUtc().toString().split('.').first;
  final storage = FlutterSecureStorage();
  final id = await storage.read(key: AppSecuredKey.id);
  // final designation = await storage.read(key: AppSecuredKey.designation);

  Map body = {
    "status": status,
    "last_repairing_start": (status==AppMachineStatus.maintenance)? currentTIme.split(" ")[0] +"T" +currentTIme.split(" ")[1] +"Z": "${machine["last_repairing_start"]}",
    "last_breakdown_start": (status==AppMachineStatus.broken)?  currentTIme.split(" ")[0] +"T" +currentTIme.split(" ")[1] +"Z" :"${machine["last_breakdown_start"]}",
    "last_problem": "$lastProblem",
    "mechanic": "$id",
  };

  DateTime startTime = DateTime.parse("${machine['last_breakdown_start']}");
  DateTime endTime = DateTime.parse(DateTime.now().toUtc().toString().split('.').first +'Z');
  String formattedDuration = endTime.difference(startTime).toString().split('.').first;

  final breakdownBody = {
    "breakdown_start": "$startTime",
    "repairing_start": "${machine['last_repairing_start']}",
    "lost_time": formattedDuration,
    "comments": "",
    "machine": "${machine['id']}",
    "mechanic": "",
    "operator": "",
    "problem_category": "$problemIndex",
    "location": "1",
    "line": "${machine['line']}",
    "mechanic": "${machine['mechanic']}",
  };


  try {
    final url = Uri.parse(AppApis.Machines + "${machine["id"]}/");
    print(url);
    print("Status supposed to be updated to $body");
    final response = await http.patch(url,body: body);
    print( "${response.statusCode} ${response.body}");
    String successMessage = (response.statusCode==200)? "Status Updated": "Status not Updated";
    if (willUpdateBreakdown) {
      final patchResponse =
      await http.post(Uri.parse(AppApis.BreakDownLogs), body: breakdownBody);
      print(breakdownBody);
      print("Breakdown updated ${patchResponse.body}");
      // Show success message

      if(patchResponse.statusCode ==200){
        successMessage = successMessage + " and Breakdown log Added";
      } else if(response.statusCode!=200){
        successMessage = successMessage + " and Breakdown log NOT Added";
      }

    } else {
      print("will not Update breaddwonLodg");
    }
    patchRequestStateUpdater(patchingState:false, message:successMessage);

  } catch (e) {
    print("Error: $e");
    final successMessage = "An error occurred while updating status.";
    patchRequestStateUpdater(patchingState: false, message:successMessage);
  }
}
