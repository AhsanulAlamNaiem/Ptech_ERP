import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ptech_erp/services/app_provider.dart';
import '../../services/appResources.dart';
import 'interaction_widgets.dart';

class AfterScanInteractionsPage extends StatefulWidget {
  Map? machine;
  AfterScanInteractionsPage({this.machine, super.key});

  @override
  _AfterScanInteractionsPageState createState() => _AfterScanInteractionsPageState();
}

class _AfterScanInteractionsPageState extends State<AfterScanInteractionsPage> {
  bool isPatching = false;
  int selectedCategoryIndex = -1;
  String? selectedCategory;
  List<dynamic> problemCategories = [];

  List<MachinePart> parts = [];
  List<MachinePart> selectedParts = [];

  int selectedSubCategoryIndex = -1;
  dynamic selectedSubCategory;
  List<dynamic> subCategories = [];
  dynamic strSelectedSubCategory;

  bool isFetchingProblemCategory = true;
  String? successMessage;

  String? questionText;
  String? status;
  String? designation;
  String? userId;


  Future<void> getDesignation() async {
    final storage = FlutterSecureStorage();
    final newDesignation = await storage.read(key: AppSecuredKey.designation);
    final newUserId = await storage.read(key: AppSecuredKey.id);
    userId = newUserId;
    designation = newDesignation;
    print("Userid: $userId");
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
    getDesignation();
    fetchProblemCategories();
    print("fetched");
  }

  Future<void> fetchProblemCategories() async {
    try {
      final response = await http.get(Uri.parse(AppApis.getProblemCategory));
      final partsResponse = await http.get(Uri.parse(AppApis.getMachineParts));

      if (response.statusCode == 200 && partsResponse.statusCode ==200) {
        setState(() {
          print("parts:${partsResponse.body}");
          parts = (jsonDecode(partsResponse.body) as List)
              .map((data) => MachinePart.fromJson(data))
              .toList();

          problemCategories = json.decode(response.body);
          isFetchingProblemCategory = false;
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
    final newMachine = context.read<AppProvider>().machine;
    if(newMachine==null){
      return Container(
          child: Card(
          child: Container(
          width: double.infinity,
          child: Padding(padding: EdgeInsets.all(10),
              child: Column(
                  children: [
                  // CircularProgressIndicator()
              ])))));
    }
    final machine = newMachine!;

    double halfScreenWidth = MediaQuery.of(context).size.width * 0.44;

        if (isFetchingProblemCategory) {
          return Center(child: CircularProgressIndicator());
        } else {
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


          return  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Card(
                  child: Container(
                      width: double.infinity,
                      child: Padding(padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              (status==null)?SizedBox(height: 0,): Text("$questionText!", style: AppStyles.textH3,),

                              SizedBox(height: 4),
                              (status==null || designation == AppDesignations.mechanic || machineStatus == AppMachineStatus.maintenance )? const SizedBox(height: 0):  problemCategories.isEmpty
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
                              (status==null || designation ==AppDesignations.mechanic || machineStatus == AppMachineStatus.maintenance )? const SizedBox(height: 0) :Container(
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
                                        print(selectedSubCategoryIndex);
                                      });
                                    },
                                  )),
                              (status==null || designation ==AppDesignations.mechanic || machineStatus == AppMachineStatus.maintenance) && !(designation == AppDesignations.mechanic) && !(designation == AppDesignations.superVisor && machineStatus==AppMachineStatus.broken)?
                              isFetchingProblemCategory?
                              Center(child: CircularProgressIndicator()):
                              Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey, width: 1), // Border color & width
                                    borderRadius: BorderRadius.circular(10), // Rounded corners
                                  ),
                                  child: false? TextField(): MultiSelectParts(
                                  parts: parts,
                                  onSelectionChanged:(List<MachinePart> newSelectedParts){
                                    setState(() {
                                      selectedParts=newSelectedParts;
                                      print("MMachineParts");
                                    });
                                  }
                              )):SizedBox(height: 0),
                            ],
                          )
                      )
                  ),
                ),
              ),

              Container(
                height: 50,
                child: Row(
                    mainAxisAlignment: (status==null) ? MainAxisAlignment.center :  MainAxisAlignment.spaceAround,
                    children: [
                     (status==null)? SizedBox(height: 0):
                     isPatching? CircularProgressIndicator(): SizedBox(
                          width: halfScreenWidth + halfScreenWidth *0.035, // Set button width to 50% of screen
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                            ),
                            onPressed: () {
                              print("$machine \n${status}\n$strSelectedSubCategory\nwillupdatebreakdown: ${designation=='Supervisor' && status =='Active'}");
                              print("sending requests.. .");
                              updateMachineStatus(
                                stateUpdater: (){
                                  setState(() {

                                  });
                                },
                                  usedPartsQtyList: selectedParts,
                                  status: status=='Repair'?"maintenance":status!.toLowerCase(),
                                  problemIndex: selectedSubCategoryIndex,
                                  willUpdateBreakdown: designation==AppDesignations.superVisor && status=='Active',
                              );
                              setState(() {

                              });
                            }, child: Text("Set to ${status}", style: AppStyles.buttonText),
                          ) ),

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
  }

  //
  Future<void> updateMachineStatus({
    required Function stateUpdater,
    required String status,
    required List<MachinePart> usedPartsQtyList,
    required int problemIndex,
    Map breakdownBody = const {},
    bool willUpdateBreakdown = false}) async {
    setState(() {
      isPatching = true;
    });

    final machine =  context.read<AppProvider>().machine!;

    final currentTIme = DateTime.now().toUtc().toString().split('.').first;

    Map body = {
      "status": status,
    };

    if(designation==AppDesignations.mechanic){
      body["mechanic"]=userId;
      body["last_repairing_start"]=currentTIme.split(" ")[0] +"T" +currentTIme.split(" ")[1] +"Z";
    } else if(status==AppMachineStatus.broken){
      body["last_breakdown_start"]=currentTIme.split(" ")[0] +"T" +currentTIme.split(" ")[1] +"Z";
    }
    if(problemIndex>0){
      body["last_problem"]=problemIndex.toString();
    }


    DateTime startTime = DateTime.parse("${machine['last_breakdown_start']}");
    DateTime endTime = DateTime.parse(DateTime.now().toUtc().toString().split('.').first +'Z');
    String formattedDuration = endTime.difference(startTime).toString().split('.').first;

    final breakdownBody = {
      "breakdown_start": "$startTime",
      "repairing_start": "${machine['last_repairing_start']}",
      "lost_time": formattedDuration,
      "comments": "",
      "machine": "${machine['id']}",
      "mechanic": "${machine['mechanic']}",
      "operator": "",
      "problem_category": "${machine['category']}",
      "location": "1",
      "line": "${machine['line']}",

    };

    try {
      final url = Uri.parse(AppApis.Machines + "${machine["id"]}/");
      print(url);
      print("Status supposed to be updated to $body");
      final response = await http.patch(url,body: body);
      print( " status update: ${response.statusCode} ${response.body}");

      if (willUpdateBreakdown) {
        final breakdownResponse =
        await http.post(Uri.parse(AppApis.BreakDownLogs), body: breakdownBody);
        final breakdown = jsonDecode(breakdownResponse.body);
        print("Breakdown updated: ${breakdownResponse.statusCode} ${breakdown}");
        if(usedPartsQtyList.isNotEmpty) {
          final formattedPartsQtyList = jsonEncode(MachinePart.formatPartsListForAPICall(parts: usedPartsQtyList, mechanicID: machine["mechanic"], breakdownId: breakdown['id']??2));
          print(" ok: $formattedPartsQtyList");
          final partsResponse = await http.post(
              Uri.parse(AppApis.bulkPartsUsage), headers: {"content-type": "application/json"}, body: formattedPartsQtyList);
          print(" parts resp: ${partsResponse.body}");
        }

      } else {
        print("will not Update BreakdwonLog");
      }


    } catch (e) {
      print("Error: $e");
      final successMessage = "An error occurred while updating status.";
    }
    setState(() {
      isPatching = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Status May be Updated! Scan again to see the update."),
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            stateUpdater();
            // Dismiss the snackbar
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
// Function to update the machine status

