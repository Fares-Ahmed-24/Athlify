import 'package:Athlify/views/auth_view/changePassword.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomEditInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final double screenWidth;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final String? initialValue;
  final Function(String)? onChanged;
  final String? hintText;
  final TextStyle? textStyle;
  final double? borderRadius;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxlength;

  const CustomEditInputField(
      {Key? key,
      required this.label,
      required this.controller,
      required this.screenWidth,
      this.keyboardType = TextInputType.text,
      this.obscureText = false,
      this.enabled = true,
      this.initialValue,
      this.onChanged,
      this.hintText,
      this.textStyle,
      this.borderRadius,
      this.inputFormatters,
      this.maxlength})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: screenWidth * 0.02),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            maxLength: maxlength,
            inputFormatters: inputFormatters,

            enabled: enabled,
            initialValue: initialValue,
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: textStyle ??
                const TextStyle(fontSize: 16), // Default text style
            decoration: InputDecoration(
              hintText: hintText,
              counter: Offstage(),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.04,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    borderRadius ?? 12), // Default border radius
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget PasswordEditField(BuildContext context, double screenWidth) {
  return Padding(
    padding: EdgeInsets.only(bottom: screenWidth * 0.05),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: screenWidth * 0.02),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: '************',
                enabled: false,
                obscureText: true,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.04,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Changepassword(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001F54),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenWidth * 0.04,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Change Password",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
