import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../appResources.dart';

class BreakdownPage extends StatefulWidget {
  const BreakdownPage({super.key});

  @override
  State<BreakdownPage> createState() => _BreakdownPageState();
}

class _BreakdownPageState extends State<BreakdownPage> {
  late Future<List<dynamic>> futurelogs;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          title: "Brekdown Logs",
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
          future: fetchlogs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Something went wrong, Make sure this device have internet connection. \n\n\nError: \n\n${snapshot.error}"));
            } else if (snapshot.hasData) {
              List logs = snapshot.data!;
              return RefreshIndicator(onRefresh:_refreshData ,child: funListViewBuilder(logs: logs));
            }
            return Center(child: Text('No data available'));
          }),
    );//Scaffold
  }


  Future<List> fetchlogs() async {
    final url = Uri.parse(
        "https://machine-maintenance.ddns.net/api/maintenance/breakdown-logs/");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      print(response.body);
      final data = jsonDecode(response.body);
      print(data);
      return data;
    } else {
      throw  Exception("failed to load log. Makesure you phone have stable internet connection");
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      futurelogs = fetchlogs(); // Refresh the data by calling the API again
    });
  }

  Widget funListViewBuilder({required List logs}) {
    return ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.fromLTRB(16, 1, 16, 1),
              child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: Colors.white,
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
                                    color: AppColors.disabledMainColor, // White background for the icon
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                padding: EdgeInsets.all(7),
                                child: Text("${logs[index]["id"]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                              ),
                              SizedBox(width: 8),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Problem: ${logs[index]["problem_category"]}", style: AppStyles.textH2),
                                    Text("${logs[index]["breakdown_start"]}", style: AppStyles.bodyTextBold),
                                    SizedBox(height: 10),
                                    Text("Lost Time: ${logs[index]["lost_time"]}", style: AppStyles.textH4),
                                    Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text("Line: ${logs[index]["line"]}", style: AppStyles.bodyTextBold),
                                          SizedBox(width: 20),
                                          Text("Machine: ${logs[index]["machine"]}", style: AppStyles.bodyTextBold)
                                        ]
                                    ),
                                    // Text("${logs[index]["status"]}")

                                  ])
                            ]
                        )
                        ]
                    ) ,
                  )));
        });
  }



  }
