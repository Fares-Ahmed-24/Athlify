import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';

class customeButton extends StatelessWidget {
  final String labelText;
  final VoidCallback onPressedCallback;
  const customeButton({
    Key? key,
    required this.onPressedCallback,
    required this.labelText,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressedCallback,
      style: ElevatedButton.styleFrom(
        backgroundColor: PrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        fixedSize: Size(385, 60),
      ),
      child:
          Text(labelText, style: TextStyle(color: Colors.white, fontSize: 24)),
    );
  }
}
