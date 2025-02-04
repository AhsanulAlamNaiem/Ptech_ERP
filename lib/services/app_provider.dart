import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier{
  String? qrCode;
  bool isScanning = true;
  bool isPatching = false;
  Map? machine;
  String? model;
  List<Map<String, dynamic>> notifications = [];

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

  updatePatchingState(bool patchingState){
    isPatching = patchingState;
    notifyListeners();
  }

  updateNotification(newNotifications){
    notifications = newNotifications;
    notifyListeners();
  }
}