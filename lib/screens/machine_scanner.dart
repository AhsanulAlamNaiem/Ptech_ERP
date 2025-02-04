import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:ptech_erp/services/app_provider.dart';
import 'Scanning/after_scan_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: context.watch<AppProvider>().isScanning
          ? QrScanner()
          : context.watch<AppProvider>().isPatching? CircularProgressIndicator():  AfterScanPage()
    );
  }
}

