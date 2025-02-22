import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ptech_erp/screens/Scanning/interaction_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:ptech_erp/services/secreatResources.dart';
import '../screens/Scanning/after_scan_page.dart';
import 'appResources.dart';
import 'database_helper.dart';

class AppProvider extends ChangeNotifier{
  String? qrCode;
  bool isScanning = true;
  bool isPatching = false;
  Map? machine;
  String? model;
  List<Map<String, dynamic>> notifications = [];
  int index = 0;
  String? designation;
  List<MachinePart> selectedParts = [];

  updateSelectedParts({required List<MachinePart> newSelectedParts}){
    selectedParts = newSelectedParts;
    notifyListeners();
  }

  updateDesignation({ required String newDesignation}){
    designation = newDesignation;
    notifyListeners();
  }

  updateQrCodeValue({ required String qrCodeValue}) async{
    qrCode = qrCodeValue;
    model = qrCodeValue;
    notifyListeners();
  }

  updateScannerState({ required bool scanningState}) async{
    isScanning = scanningState;
    notifyListeners();
  }

  updateMachineData(Map newMachine) async{
    machine = newMachine;
  }

  updateMachineDatawithOutNotification(Map newMachine) async{
    machine = newMachine;
  }


  updatePatchingState(bool patchingState){
    isPatching = patchingState;
    notifyListeners();
  }

  loadNotification() async{
    notifications = await DatabaseHelper().getNotifications();
    notifyListeners();
  }

  reLoadMachineData() async{

    final queryParams = {
      'machine_id': '$qrCode'
    };

    final url = Uri.parse(AppApis.Machines).replace(queryParameters: queryParams);

    final headers = {'Content-Type': 'application/json'};
    final response = await http.get(url);
    Map<String,dynamic> jsonDecodedData = jsonDecode(response.body);

    Map machineObject = jsonDecodedData['results'][0];
    machine = machineObject;
    print("Machine inside provider updated");
    notifyListeners();
  }

  Future<void> deleteAllNotifications() async {
    await DatabaseHelper().deleteAllNotifications();
    notifications.clear();
    notifyListeners();
  }

  setIndex(int newIndex){
    index = newIndex;
    notifyListeners();
  }
}