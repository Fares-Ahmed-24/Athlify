import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Athlify/constant/Constants.dart';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final int? maxlength;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextFormField({
    Key? key,
    required this.labelText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon = Icons.text_fields,
    this.maxlength,
    this.validator,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          validator: validator ??
              (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field cannot be empty';
                }
                return null;
              },
          obscureText: obscureText,
          keyboardType: keyboardType,
          cursorColor: Colors.black,
          showCursor: true,
          maxLength: maxlength,
          inputFormatters: inputFormatters ?? [],
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            filled: true,
            fillColor: ContainerColor, // Replace with your ContainerColor
            labelText: labelText,
            suffixIcon: suffixIcon,
            prefixIcon: Icon(prefixIcon),
            counter: Offstage(),
            labelStyle: const TextStyle(
              fontSize: 18,
              color:
                  SecondaryContainerText, // Replace with your SecondaryContainerText
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(25),
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
