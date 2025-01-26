import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ptech_erp/screens/Scanning/patch_reques_sender.dart';

import '../../appResources.dart';

class MachineDetailsPage extends StatefulWidget {
  final Map machineDetails;
  final Function pressedScanAgain;
  final Function refreashData;
  const MachineDetailsPage({super.key, required this.machineDetails, required this.pressedScanAgain, required this.refreashData});

  @override
  _MachineDetailsPageState createState() => _MachineDetailsPageState();
}

class _MachineDetailsPageState extends State<MachineDetailsPage> {
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
    final securedDesignation = "designation";
    final designation = await storage.read(key: securedDesignation);

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
    final machine = widget.machineDetails;

    return FutureBuilder(
      future: getDesignation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          final designation = snapshot.data ?? "Unknown";
          final machineStatus = machine['status'];

          if (designation == "Supervisor") {
            if (machineStatus == 'active') {
              status = "Broken";
              questionText =
              'Is the Machine Broken?\nif yes, at first select problem category and then press "Set to $status" Button';
            }
            else if (machineStatus == 'maintenance') {
              status = "Active";
              questionText =
              'Is the Machine Active now?\nif yes, at first select problem category and then press "Set to $status" Button';
            }
          } else if (designation == 'Mechanic' && machineStatus == 'broken') {
            status = "Repair";
            questionText =
            'The Machine is Broken?\nTo set it in Maintenance stage press "Set to $status" Button';
          }


          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 3,
                    child: Card(child: Container(
                        width: double.infinity,
                        child: Padding(padding: EdgeInsets.all(10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text("Machine ID: ${machine['machine_id']}",
                                    style: AppStyles.textH2,),
                                  SizedBox(height: 10),
                                  Text(
                                      "Model Number: ${machine['model_number']}",
                                      style: AppStyles.textH3),
                                  Text("Serial No: ${machine['serial_no']}",
                                      style: AppStyles.textH3),
                                  SizedBox(height: 10),
                                  Text("Line: ${machine['line']}",
                                      style: AppStyles.textH3),
                                  Text("Sequence: ${machine['sequence']}",
                                      style: AppStyles.textH3),
                                  SizedBox(height: 10),
                                  Text("Status: $machineStatus",
                                      style: AppStyles.textH3),
                                ]
                            ))))
                ),

                Expanded(
                  flex: 3,
                  child: Card(

                    child: Container(
                        width: double.infinity,
                        child: Padding(padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                (status==null)?SizedBox(height: 0,): Text("$questionText!", style: AppStyles.textH3,),

                                Spacer(),
                                (status==null || designation =='Mechanic' )? const SizedBox(height: 0):  problemCategories.isEmpty
                                      ? const CircularProgressIndicator()
                                      : DropdownButton<String>(
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
                                  ),

                                designation=='Supervisor'? const SizedBox(height: 5.0): const SizedBox(height: 0),
                                (status==null || designation =='Mechanic' )? const SizedBox(height: 0):                  DropdownButton<String>(
                                  value: selectedSubCategory,
                                  hint: const Text("Select Subcategory"),
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
                                ),


                                ],
                            )
                        )
                    ),
                  ),
                ),

                Expanded(
                  flex: 1,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        isPatching? CircularProgressIndicator(): (status==null)? SizedBox(height: 0): ElevatedButton(
                            onPressed: () {
                              print("$machine \n${status}\n$strSelectedSubCategory\nwillupdatebreakdown: ${designation=='Supervisor' && status =='Active'}");
                              updateMachineStatus(
                                machine: machine,
                                status: status=='Repair'?"maintenance":status!.toLowerCase(),
                                lastProblem: strSelectedSubCategory??"Null",
                                problemIndex: selectedSubCategoryIndex,
                                willUpdateBreakdown: designation=='Supervisor' && status=='Active',

                                patchRequestStateUpdater: ({required bool patchingState, String? message=null}){
                                  setState(() {
                                    isPatching = patchingState;
                                  });
                                  patchingState? widget.refreashData(): print("will update state");

                                  !(message==null)? ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                      Text(message),
                                      duration: Duration(seconds: 3),
                                    ),
                                  ):print("No message");
                                }
                              );
                            }, child: Text("Set to ${status}"),
                        ),


                        ElevatedButton(onPressed: () {
                          widget.pressedScanAgain();
                        }, child: Text("Scan Again"),
                        ),
                      ]
                  ),
                )
                // SizedBox(height: 50),
                // Display based on conditions,
              ],
            ),
          );
        }
      },
    );
  }
}
// Function to update the machine status
