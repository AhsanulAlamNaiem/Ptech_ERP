import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ptech_erp/screens/home_screen.dart';

import '../appResources.dart';
import 'breakdown.dart';

class Maintanance extends StatelessWidget {
  const Maintanance({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: customAppBar(
          title: "Maintanance",
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color:Colors.white)),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(
            children: [
              Btn("All Machines", AllMaintainances()),
              Btn("BreakdownLogs", BreakdownPage()),
            ],
          ),
        ),
      ),
    );
  }
}

class AllMaintainances extends StatefulWidget {
  const AllMaintainances({super.key});

  @override
  _MachineListScreenState createState() => _MachineListScreenState();
}

class _MachineListScreenState extends State<AllMaintainances> {
  late Future<List<dynamic>> futureMachines;

  @override
  void initState() {
    super.initState();
    futureMachines = fetchMachines(); // Initial fetch
  }

  // Method to refresh data
  Future<void> _refreshData() async {
    setState(() {
      futureMachines =
          fetchMachines(); // Refresh the data by calling the API again
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          title: "All Machines",
        leading: IconButton(
          onPressed: () {
    Navigator.pop(context);
    },
        icon: Icon(Icons.arrow_back)),
          action: [
            IconButton(onPressed: _refreshData, icon: Icon(Icons.refresh,))
          ]
    ),
      body: FutureBuilder<List>(
          future: fetchMachines(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                      "Something went wrong, Make sure this device have internet connection. \n\n\nError: \n\n${snapshot.error}"));
            } else if (snapshot.hasData) {
              List machines = snapshot.data!;
              return RefreshIndicator(
                  onRefresh: _refreshData,
                  child: funListViewBuilder(machines: machines));
            }
            return Center(child: Text('No data available'));
          }),
    ); //Scaffold
  }
}

Future<List> fetchMachines() async {
  final url = Uri.parse(
      "https://machine-maintenance.ddns.net/api/maintenance/machines/");

  final response = await http.get(url);
  if (response.statusCode == 200) {
    print(response.body);
    final data = jsonDecode(response.body);
    print(data);
    return data;
  } else {
    throw Exception(
        "failed to load machine. Makesure you phone have stable internet connection");
  }
}

Widget funListViewBuilder({required List machines}) {
  return ListView.builder(
      itemCount: machines.length,
      itemBuilder: (context, index) {
        final status = machines[index]["status"];
        bool isbroken = false;
        bool isInRepair = false;
        if(status=="broken"){ isbroken = true;} else if(status == "maintenance"){isInRepair==true;}

        return Padding(
            padding: EdgeInsets.fromLTRB(16, 1, 16, 1),
            child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Card(
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                          ),
                      color: isbroken? AppColors.disabledMainColor: isInRepair? AppColors.accentColor : Colors.white,
                      child:  Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(width: 10),
                    Container(
                      alignment: Alignment.center,
                      height: 80,
                      width: 60,
                      decoration: BoxDecoration(
                          color: isbroken? Colors.white: isInRepair? Colors.white : AppColors.disabledMainColor, // White background for the icon
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      padding: EdgeInsets.all(7),
                      child: Text("${machines[index]["id"]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    ),
                    SizedBox(width: 8),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    Text("Id: ${machines[index]["machine_id"]}", style: AppStyles.textH2),
                    Text("Model: ${machines[index]["model_number"]}", style: AppStyles.textH4),
                    Text("Breakdown: ${machines[index]["last_breakdown_start"]}", style: AppStyles.bodyTextBold),
                    Text("Last Problem: ${machines[index]["last_problem"]}", style: AppStyles.textH4),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                        Text("Line: ${machines[index]["line"]}", style: AppStyles.bodyTextBold),
                        SizedBox(width: 20),
                        Text("Operator: ${machines[index]["operator"]}", style: AppStyles.bodyTextBold)
                      ]
                    ),
                          // Text("${machines[index]["status"]}")

                    ])
                  ]
              )
              ]
          ) ,
        )));
      });
}
