import 'package:flutter/material.dart';

class CustomeSwitch extends StatefulWidget {
  const CustomeSwitch({super.key});

  @override
  State<CustomeSwitch> createState() => _MyWidgetState();
}

bool _isActive = false;

class _MyWidgetState extends State<CustomeSwitch> {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
        value: _isActive,
        title: Text(
          'Dark Mode',
          style: TextStyle(color: Colors.white),
        ),
        secondary: Icon(
          Icons.dark_mode,
          color: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            _isActive = value;
          });
        });
  }
}
