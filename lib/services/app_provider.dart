import 'package:flutter/material.dart';

import '../screens/Scanning/after_scan_page.dart';
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
    notifyListeners();
  }

  loadMachineData() async {
    updatePatchingState(true);

    final fetchedMachine = await funcFetchMachineDetails(model!);

    if (fetchedMachine == null || fetchedMachine.isEmpty) {
      machine = null;
    } else {
      machine = Map.from(fetchedMachine);
    }

    updatePatchingState(false);
    notifyListeners();
  }


  updatePatchingState(bool patchingState){
    isPatching = patchingState;
    notifyListeners();
  }

  loadNotification() async{
    notifications = await DatabaseHelper().getNotifications();
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