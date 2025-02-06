import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import '../../services/appResources.dart';

class MachinePart {
  final String name;
  int quantity;

  MachinePart({required this.name, this.quantity = 0});
}

Widget multiSelectDropDown({ required List<MachinePart> parts, required Function setSelectedPartslist}){
  List<MachinePart> selectedParts = [];
  return Expanded(
    flex: 5,
    child: Card(
      child: Container(
          width: double.infinity,
          child: Padding(padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                        border: Border.all(color: AppColors.disabledMainColor, width: 1), // Border styling
                      ),
                      child: MultiSelectDialogField(
                        title: Text("Select Broken Parts"),

                        items: parts.map((part) => MultiSelectItem<MachinePart>(part, part.name,)).toList(),

                        onConfirm: (values) {
                          selectedParts = values;
                          setSelectedPartslist(selectedParts);
                        },
                      )),
                ],
              )
          )
      ),
    ),
  );
}

Widget addQuantity({ required List<MachinePart> selectedParts, required Function setSelectedPartslist}){
    return               Column(
      children: selectedParts.map((part) {
        return Row(
          children: [
            Expanded(child: Text(part.name)),
            SizedBox(
              width: 60,
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() {
                    part.quantity = int.tryParse(val) ?? 0;
                  });
                },
                decoration: InputDecoration(hintText: "Qty"),
              ),
            ),
          ],
        );
      }).toList(),
    );
}