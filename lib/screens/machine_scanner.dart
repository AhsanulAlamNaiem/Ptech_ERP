import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../appResources.dart';
import 'Scanning/machine_details.dart';
import 'Scanning/scanner_screen.dart';

class MachineScanner extends StatefulWidget {
  const MachineScanner({super.key});

  @override
  _MachineScannerPageState createState() => _MachineScannerPageState();
}

class _MachineScannerPageState extends State<MachineScanner> {
  String? qrCodeValue;
  bool isScanning = true;
  final storage = FlutterSecureStorage();
  final securedDesignation = "designation";
  bool isScanned = false;

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
    return null;
  }

  Widget funcMachineDetailsBuilder({required String model, required Function pressedScanAgain}) {
    return FutureBuilder(
      future: funcFetchMachineDetails(model),
      builder: (context, snapshot) {
        print(snapshot.hasData);
        print(snapshot.data);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: Column(
            children: [Text("Model: $model"), CircularProgressIndicator()],
          ));
        } else if (snapshot.hasData) {
          return MachineDetailsPage(
            machineDetails: snapshot.data!,
            pressedScanAgain: pressedScanAgain,
            refreashData:(){
              setState(() {
                isScanning=false;
              });
            }
          );
        } else {
          return Center(
            child: Column(
              children: [Text("No data Available")],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isScanning
          ? QrScanner( onScan: (String scannedText){
            setState(() {
              qrCodeValue = scannedText;
              isScanning = false;
            });
      } ,)
          : funcMachineDetailsBuilder(
              model: qrCodeValue ?? "No Model Detected",
        pressedScanAgain: (){
          setState(() {
            isScanning = !isScanning;
          });
        }
        )
    );
  }
}

