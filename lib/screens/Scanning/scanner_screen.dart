import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:ptech_erp/services/app_provider.dart';
import 'package:vibration/vibration.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});
  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScanner> {
  String? qrCodeValue;
  bool isScanning = true;
  final storage = FlutterSecureStorage();
  final securedDesignation = "designation";
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
              flex: 1,
              child: Text("")),
          Expanded(
            flex: 7,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: SizedBox(
                width: 250,  // Set the width for the scanner
                height: 290, // Set the height for the scanner
                  child:  MobileScanner(
                      onDetect: (BarcodeCapture capture) async {
                      print(isScanned);
                      if (capture.raw != null) {
                        setState(() {
                          qrCodeValue = capture.barcodes[0].rawValue;
                          context.read<AppProvider>().updateQrCodeValue(qrCodeValue: qrCodeValue!);
                          print(context.read<AppProvider>().qrCode);
                          context.read<AppProvider>().updateScannerState(scanningState: false);
                    // Trigger a single vibration
                    Vibration.vibrate();
                  });
                }
              },
            ))),
          ),
          Expanded(
            flex: 1,
          child: Text("")),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                qrCodeValue ?? 'Scan QR Code of the Machine',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }
  }
}