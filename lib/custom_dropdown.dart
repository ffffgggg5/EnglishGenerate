import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final List<String> items;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
