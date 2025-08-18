import 'package:flutter/material.dart';

class Passwordtf extends StatefulWidget {
  final String labelText;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?) validator;  // Validator function added here

  const Passwordtf({
    super.key,
    required this.labelText,
    required this.icon,
    required this.controller,
    required this.validator,  // Updated constructor to accept validator
  });

  @override
  _PasswordtfState createState() => _PasswordtfState();
}

class _PasswordtfState extends State<Passwordtf> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,  // Validator added to TextFormField
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(widget.icon, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: _togglePasswordVisibility,
        ),
        filled: true,
        fillColor: const Color(0xffF4F4F4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
    );
  }
}
