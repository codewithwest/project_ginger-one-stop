import 'package:flutter/material.dart';

class DropDownMenuUtil extends StatefulWidget {
  DropDownMenuUtil({
    super.key,
    required this.mappedArray,
    required this.stateValue,
    required this.value,
    required this.label,
    required this.stateUpdater,
  });

  List<Map<String, String>> mappedArray;
  late String? stateValue;
  late String? value;
  late String? label;
  late Function? stateUpdater;

  @override
  State<DropDownMenuUtil> createState() => _DropDownMenuUtilState();
}

class _DropDownMenuUtilState extends State<DropDownMenuUtil> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      initialSelection: "",
      onSelected: (String? value) {
        setState(
          () {
            widget.stateValue = value!;
            widget.stateUpdater!(widget.label, value);
          },
        );
      },
      dropdownMenuEntries:
          widget.mappedArray.map<DropdownMenuEntry<String>>((item) {
        return DropdownMenuEntry(
          value: item[widget.value] ?? "",
          label: item[widget.label] ?? "",
        );
      }).toList(),
    );
  }
}
