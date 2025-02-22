import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ptech_erp/services/app_provider.dart';
import '../../services/appResources.dart';
import '../../services/secreatResources.dart';
import 'interaction_widgets.dart';

class AfterScanInteractionsPage extends StatefulWidget {

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
    final machine = context.watch<AppProvider>().machine!;

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


      return Container(
          height: max(365,selectedParts.length*45+235),
          child: Column(
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
                                          print("what");
                                          print(selectedParts.length*45+50);
                                          print(selectedParts.length);
                                        });
                                      }
                                  )):SizedBox(height: 0),
                            ],
                          )
                      )
                  ),
                ),
              ),
              Spacer(),

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
                              print(selectedCategoryIndex);
                              if(selectedCategoryIndex==-1 && machineStatus==AppMachineStatus.active){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text('No Category Selected'),
                                    duration: Duration(seconds: 1), // Show for 1 second
                                  ),
                                );
                                return;
                              }
                              print("$machine \n${status}\n$strSelectedSubCategory");
                              print("sending requests.. .");
                              updateMachineStatus(
                                stateUpdater: (){
                                  setState(() {

                                  });
                                },
                                usedPartsQtyList: selectedParts,
                                status: status=='Repair'?"maintenance":status!.toLowerCase(),
                                problemIndex: selectedSubCategoryIndex,
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
                              Navigator.pop(context);
                            }, child: Text("Scan Again",  style: AppStyles.buttonText,),
                          )),
                    ]
                ),
              )
              // SizedBox(height: 50),
              // Display based on conditions,
            ],
          ));
    }
  }

  //
  Future<void> updateMachineStatus({
    required Function stateUpdater,
    required String status,
    required List<MachinePart> usedPartsQtyList,
    required int problemIndex}) async {
    setState(() {
      isPatching = true;
    });

    final machine = Provider.of<AppProvider>(context, listen: false).machine!;
    Map body = {};
    final headers = {"Content-Type": "application/json"};
    String url = "";

    if(designation==AppDesignations.superVisor && status == AppMachineStatus.broken){
      body["problem_category"]=problemIndex;
      url = "${AppApis.Machines}${machine['id']}/start_breakdown/";
    } else if(designation==AppDesignations.mechanic && status == AppMachineStatus.maintenance){
      body["mechanic"]=userId;
      url = "${AppApis.Machines}${machine['id']}/start_repair/";
    }else if(designation==AppDesignations.superVisor && status == AppMachineStatus.active){
      body["parts_used"]=MachinePart.formatPartsListForAPICall(parts: usedPartsQtyList);
      url = "${AppApis.Machines}${machine['id']}/complete_repair/";
    }

    try {
      final uriUrl = Uri.parse(url);
      print(uriUrl);
      print(body);
      return;
      final response = await http.post(uriUrl,body: jsonEncode(body), headers: headers);
      print( "Status Update: ${response.statusCode} ${response.body}");
    } catch (e) {
      print("Error: $e");
    }

    Provider.of<AppProvider>(context, listen: false).reLoadMachineData();
    setState(() {
      isPatching = false;
    });
    return;
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

