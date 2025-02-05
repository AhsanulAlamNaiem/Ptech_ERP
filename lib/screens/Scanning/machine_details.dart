import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:ptech_erp/services/app_provider.dart';

import '../../services/appResources.dart';

class MachineDetailsPage extends StatefulWidget {
  @override
  _MachineDetailsPageState createState() => _MachineDetailsPageState();
}

class _MachineDetailsPageState extends State<MachineDetailsPage> {

  Future<String?> getDesignation() async {
    final storage = FlutterSecureStorage();

    final designation = await storage.read(key: AppSecuredKey.designation);

    return designation;
  }


  @override
  Widget build(BuildContext context) {
    final machine = context
        .read<AppProvider>()
        .machine!;
    final machineStatus = machine['status'];

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(child: Container(
              width: double.infinity,
              child: Padding(padding: EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("Machine ID: ${machine['machine_id']}",
                          style: AppStyles.textH2,),
                        SizedBox(height: 15),
                        Text("Model Number: ${machine['model_number']}",
                            style: AppStyles.textH2),
                        Text("Serial No: ${machine['serial_no']}",
                            style: AppStyles.textH2),
                        SizedBox(height: 15),
                        Text("Line: ${machine['line']}",
                            style: AppStyles.textH2),
                        Text("Sequence: ${machine['sequence']}",
                            style: AppStyles.textH2),
                        SizedBox(height: 10),
                        Text("Last Problem: ${machine['last_problem']}",
                            style: AppStyles.textH2),
                        Text("Status: $machineStatus",
                            style: AppStyles.textH2),
                      ]
                  )))),
          // SizedBox(height: 50),
          // Display based on conditions,
        ],
      ),
    );
  }
}
// Function to update the machine status
