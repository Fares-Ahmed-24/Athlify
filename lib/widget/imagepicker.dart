import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';

class Imagepicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: SecondaryContainerText),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(child: Icon(Icons.add, size: 40, color: Colors.grey)),
      ),
    );
  }
}
