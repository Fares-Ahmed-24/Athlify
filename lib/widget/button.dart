import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';

class Custbutton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const Custbutton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: ContainerColor, fontSize: 20),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: PrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
