import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';

class CustomeDivider extends StatelessWidget {
  final String TextDriver;

  const CustomeDivider({super.key, required this.TextDriver});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: SecondaryContainerText, // Light grey color
              thickness: 1, // Thickness of the line
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              TextDriver,
              style: const TextStyle(
                fontSize: 16,
                color: SecondaryContainerText, // Text color
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: SecondaryContainerText, // Light grey color
              thickness: 1, // Thickness of the line
            ),
          ),
        ],
      ),
    );
  }
}
