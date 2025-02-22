import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:ptech_erp/services/app_provider.dart';
import 'package:vibration/vibration.dart';
import '../services/appResources.dart';
import '../services/secreatResources.dart';
import 'Scanning/after_scan_page.dart';
import 'Scanning/scanner_screen.dart';
import 'package:http/http.dart' as http;

class MachineScanner extends StatefulWidget {
  const MachineScanner({super.key});

  @override
  _MachineScannerPageState createState() => _MachineScannerPageState();
}

class _MachineScannerPageState extends State<MachineScanner> {
  String? qrCodeValue;
  bool isErrorInLoadingMachineData = false;
  double? halfScreenWidth;
  final storage = FlutterSecureStorage();
  final securedDesignation = "designation";

  @override
  Widget build(BuildContext context) {

    {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
                !context.read<AppProvider>().isScanning? "Scanned Machine: $qrCodeValue":'Scan QR Code of the Machine',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
          Expanded(
            flex: 7,
            child: Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, isErrorInLoadingMachineData?5:50), child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: isErrorInLoadingMachineData?
                noDataScreen(text:"No data Found,\nor something went wrong!"): (!context.watch<AppProvider>().isScanning)?  Center(child: CircularProgressIndicator()): SizedBox(
                    width: 250,  // Set the width for the scanner
                    height: 290, // Set the height for the scanner
                    child:  MobileScanner(
                      onDetect: (BarcodeCapture capture) async {
                        if (capture.raw != null) {
                          setState(() {
                            qrCodeValue = capture.barcodes[0].rawValue;
                            print(context.read<AppProvider>().qrCode);
                            context.read<AppProvider>().updateQrCodeValue(qrCodeValue: qrCodeValue!);
                            context.read<AppProvider>().updateScannerState(scanningState: false);
                            // Trigger a single vibration
                            Vibration.vibrate();
                          });
                          navigateToAfterScanPage(qrCodeValue!);
                        }
                      },
                    )))),
          )
        ],
      );
    }
  }


  Future<Map?> navigateToAfterScanPage(String model) async {
    final queryParams = {
      'machine_id': '$model'
    };
    final url = Uri.parse(AppApis.Machines).replace(queryParameters: queryParams);
    print(url);

    final headers = {'Content-Type': 'application/json'};
    final response = await http.get(url);

    print(response.statusCode);
    Map<String, dynamic> jsonDecodedData = jsonDecode(response.body);

    try {
      Map machineObject = jsonDecodedData['results'][0];
      print("machine Object: $machineObject");
      context.read<AppProvider>().updateMachineDatawithOutNotification(machineObject!);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>AfterScanPage()));
    } catch (e) {
      print("error");
      setState(() {
        isErrorInLoadingMachineData=true;
      });
    }
  }


  Widget noDataScreen({required String text}){
    halfScreenWidth = MediaQuery.of(context).size.width * 0.44;
    return Center(
        child:Container(
            height: 500,
            child: Column(children: [
              Spacer(),
              Text(text,style: AppStyles.textH3, textAlign: TextAlign.center,),
              Spacer(),
              SizedBox(
                  width: halfScreenWidth!-halfScreenWidth!*0.05, // Set button width to 50% of screen
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    ),
                    onPressed: () {
                      setState(() {
                        context.read<AppProvider>().updateScannerState(scanningState: true);
                        isErrorInLoadingMachineData=false;
                      });
                    }, child: Text("Scan Again",  style: AppStyles.buttonText,),
                  )),
            ])));
  }

}

