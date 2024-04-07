import 'package:flutter/material.dart';

const List<String> list = <String>[
  'حضانة',
  'أولى و تانية',
  'تالتة و رابعة',
  'خامسة و سادسة',
  'اعدادي',
  'ثانوي'
];

class YearDropdown extends StatefulWidget {
  const YearDropdown({super.key});

  @override
  State<YearDropdown> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<YearDropdown> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(32.0),
      color: Colors.transparent,
      child: DropdownButton<String>(
        value: dropdownValue,
        icon: const Icon(Icons.arrow_drop_down),
        elevation: 16,
        style: const TextStyle(color: Colors.deepPurple),
        underline: Container(
          height: 2,
          color: Colors.deepPurpleAccent,
        ),
        onChanged: (String? value) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = value!;
          });
        },
        items: list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
