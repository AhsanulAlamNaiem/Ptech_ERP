import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ptech_erp/services/appResources.dart';
import 'package:http/http.dart' as http;
import '../services/secreatResources.dart';
import 'Scanning/interaction_widgets.dart';



class InventoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return InventoryPageState();
  }
}

class InventoryPageState extends State<InventoryPage>{
  List<MachinePart> parts = [];
  List<MachinePart> selectedParts = [];
  bool isFetchingProblemCategory = true;

  @override
  void initState() {
    super.initState();
    print("initiated");
    fetchProblemCategories();
    print("fetched");
  }

  Future<void> fetchProblemCategories() async {
    try {
      final partsResponse = await http.get(Uri.parse(AppApis.getMachineParts));

      if (partsResponse.statusCode ==200) {
        setState(() {
          print("parts:${partsResponse.body}");
          parts = (jsonDecode(partsResponse.body) as List)
              .map((data) => MachinePart.fromJson(data))
              .toList();
          isFetchingProblemCategory = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: customAppBar(
          title: "Inventory",
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
        ),
        body: isFetchingProblemCategory? Center( child:  CircularProgressIndicator()) : MultiSelectParts(
            parts: parts,
            onSelectionChanged:(List<MachinePart> newSelectedParts){
              selectedParts=newSelectedParts;
            }
          )
        ),
      );
  }
}

