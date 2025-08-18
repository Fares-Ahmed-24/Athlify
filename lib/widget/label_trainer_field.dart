// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class buildLabel extends StatelessWidget {
  buildLabel({required this.text});
  String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    );
  }
}
