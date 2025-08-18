import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';

class Clubsfilterchip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onSelected; // Add callback for handling selection

  // Constructor now requires the onSelected callback
  Clubsfilterchip({
    required this.isSelected,
    required this.label,
    this.onSelected, // Add it to the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        // Handle tap event
        onTap: onSelected, // Call the onSelected callback when tapped
        child: Chip(
          label: Text(label),
          backgroundColor: isSelected ? PrimaryColor : Colors.grey.shade300,
          labelStyle:
              TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
