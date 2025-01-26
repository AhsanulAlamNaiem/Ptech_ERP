import 'package:flutter/material.dart';
import 'package:ptech_erp/appResources.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

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
        body: Center(
          child: Text("Inventories page"),
        ),
      ),
    );
  }
}

