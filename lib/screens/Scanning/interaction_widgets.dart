import 'dart:math';

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ptech_erp/services/app_provider.dart';

class MachinePart {
  final int part_id;
  final String name;
  int quantity_used;
  int availableQty;// Quantity user selects


  MachinePart({
    required this.part_id,
    required this.name,
    this.quantity_used = 0,
    required this.availableQty,
  });

  // Convert JSON to MachinePart object
  factory MachinePart.fromJson(Map<String, dynamic> json) {
    return MachinePart(
      part_id: json['id'],
      name: json['name'],
      availableQty: json['quantity'],
    );
  }

  // Convert list of MachineParts to required JSON structure
  static List<Map<String, dynamic>> formatPartsListForAPICall({
    required List<MachinePart> parts
  }) {
    return parts.map((part) {
      return {
        "part_id": part.part_id,
        "quantity_used": part.quantity_used,
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
  final parts = widget.parts;
  final TextEditingController _controller = TextEditingController();
      // .where((part){return part.availableQty>0;}).toList().cast<MachinePart>();
    return  Padding(padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: 46,
                child:MultiSelectDialogField(
                  chipDisplay: MultiSelectChipDisplay.none(),
                  items: parts
                      .map((part) =>  MultiSelectItem<MachinePart>(part, part.name))
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
              child: Row( children: [
                Expanded(
                    flex: 6,
                    child: TextField(
                      controller: _controller,
                style: TextStyle(fontSize: 13),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                    if(int.parse(val)>part.availableQty){
                      _controller.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Used Quantity Can not be Greater than Available Quantity"),
                          action: SnackBarAction(
                            label: 'Close',
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            },
                          ),
                        ),
                      );
                      setState(() {
                      });
                      return;
                    }
                    part.quantity_used = int.tryParse(val) ?? 0;
                    print("Part quantity: ${part.quantity_used}");
                    widget.onSelectionChanged(selectedParts);
                    setState(() {
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Used qty of ${part.name}", style: TextStyle(fontSize: 13),),
                ),
              )),
              Expanded(flex:1, child: Text(" (${part.availableQty})"))])));
            }

        )),
      ],
    ));
  }
}
