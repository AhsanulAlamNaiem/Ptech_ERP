import 'dart:math';

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ptech_erp/services/app_provider.dart';

class MachinePart {
  final int id;
  final String name;
  final double price;
  int availableQuantity; // Stock quantity from API
  int selectedQuantity;  // Quantity user selects
  final int company;

  MachinePart({
    required this.id,
    required this.name,
    required this.price,
    required this.availableQuantity,
    required this.company,
    this.selectedQuantity = 0,
  });

  // Convert JSON to MachinePart object
  factory MachinePart.fromJson(Map<String, dynamic> json) {
    return MachinePart(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price']),  // Convert to double
      availableQuantity: json['quantity'],
      company: json['company'],
    );
  }

  // Convert list of MachineParts to required JSON structure
  static List<Map<String, dynamic>> formatPartsListForAPICall({
    required List<MachinePart> parts,
    required int mechanicId,
    required int breakdownId,
  }) {
    return parts.map((part) {
      return {
        "quantity_used": part.selectedQuantity,
        "remarks": "",
        "part": part.id,
        "mechanic": mechanicId,
        "breakdown": breakdownId,
        "company": part.company,
      };
    }).toList();
  }
}


class MultiSelectParts extends StatefulWidget {
  final List<MachinePart> parts;
  final Function(List<MachinePart>) onSelectionChanged;

  const MultiSelectParts({
    Key? key,
    required this.parts,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  _MultiSelectPartsState createState() => _MultiSelectPartsState();
}

class _MultiSelectPartsState extends State<MultiSelectParts> {
  List<MachinePart> selectedParts = [];

  @override
  Widget build(BuildContext context) {
    return  Padding(padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: 46,
                child:MultiSelectDialogField(
                  chipDisplay: MultiSelectChipDisplay.none(),
                  items: widget.parts
                      .map((part) => MultiSelectItem<MachinePart>(part, part.name))
                      .toList(),
          title: Text("Add Parts"),
          searchable: true,
          buttonText: Text("Select Broken Parts"),
          onConfirm: (values) {
            setState(() {
              selectedParts = List<MachinePart>.from(values);
            });
            widget.onSelectionChanged(selectedParts);
            // context.read<AppProvider>().updateSelectedParts(newSelectedParts: selectedParts);
          },
        )),
        SizedBox(height: 10),
        // Show selected parts with quantity input
        selectedParts.isEmpty? SizedBox(height: 0,):
        Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1), // Border color & width
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child:  ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
            itemCount: selectedParts.length,
            itemBuilder: (context, index) {
              MachinePart part = selectedParts[index];
              return Padding(padding: EdgeInsets.all(5),
              child: SizedBox(height: 35,
              child:  TextField(
                style: TextStyle(fontSize: 13),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() {
                    part.selectedQuantity = int.tryParse(val) ?? 0;
                    print("Part quantity: ${part.selectedQuantity}");
                    widget.onSelectionChanged(selectedParts);
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Used qty of ${part.name}", style: TextStyle(fontSize: 13),),
                ),
              )));
            }

        )),
      ],
    ));
  }
}
