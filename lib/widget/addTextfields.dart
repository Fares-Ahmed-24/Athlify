import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Athlify/constant/Constants.dart';

class CustomaddTextFormField extends StatelessWidget {
  final String hintText;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final int? maxlength;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final double? widthTextField;
  final int? maxlines;

  const CustomaddTextFormField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxlength,
    this.validator,
    this.maxlines,
    this.inputFormatters,
    this.widthTextField,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Container(
            width: widthTextField,
            child: TextFormField(
              controller: controller,
              validator: validator ??
                  (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field cannot be empty';
                    }
                    return null;
                  },
              keyboardType: keyboardType,
              cursorColor: Colors.black,
              maxLines: maxlines,
              showCursor: true,
              maxLength: maxlength,
              inputFormatters: inputFormatters ?? [],
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                filled: true,
                fillColor: ContainerColor,
                hintText: hintText,
                counter: Offstage(),
                labelStyle: const TextStyle(
                  fontSize: 18,
                  color:
                      SecondaryContainerText, // Replace with your SecondaryContainerText
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
