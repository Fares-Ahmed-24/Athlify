import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/widget/button.dart';
import 'package:Athlify/widget/passwordTf.dart';
import 'package:Athlify/services/auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Changepassword extends StatefulWidget {
  const Changepassword({super.key});

  @override
  State<Changepassword> createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  final auth = AuthService();
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController verfiyPasswordController = TextEditingController();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.05),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back),
                ),
              ),
              Container(
                height: screenHeight * 0.3,
                width: screenWidth * 0.8,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    Icons.lock_outline,
                    color: Colors.grey[350],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: PrimaryColor,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Please set new password to continue.',
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Column(
                children: [
                  Passwordtf(
                    labelText: 'Current Password',
                    icon: Icons.lock_outline_rounded,
                    controller: passwordController,
                    validator: _validatePassword,
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Passwordtf(
                    labelText: 'New Password',
                    icon: Icons.lock_reset_rounded,
                    controller: newPasswordController,
                    validator: _validatePassword,
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Passwordtf(
                    labelText: 'Confirm New Password',
                    icon: Icons.verified_user_outlined,
                    controller: verfiyPasswordController,
                    validator: _validatePassword,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey[600],
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Text(
                        'Password must be at least 8 characters long and include a mix of letters, numbers, and symbols.',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Custbutton(
                text: 'Change Password',
                onPressed: () async {
                  final email = prefs.getString('email') ?? '';
                  final currentPassword = passwordController.text.trim();
                  final newPassword = newPasswordController.text.trim();
                  final confirmPassword = verfiyPasswordController.text.trim();

                  // Validation
                  if (currentPassword.isEmpty ||
                      newPassword.isEmpty ||
                      confirmPassword.isEmpty) {
                    return _showDialog('Error', 'All fields are required');
                  }

                  if (newPassword != confirmPassword) {
                    return _showDialog('Error', 'New passwords do not match');
                  }

                  if (!_isStrongPassword(newPassword)) {
                    return _showDialog(
                      'Weak Password',
                      'Password must be at least 8 characters and include letters, numbers, and symbols.',
                    );
                  }

                  final result = await auth.changePassword(
                      email, currentPassword, newPassword);

                  if (result['success']) {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.success,
                      title: 'Success',
                      desc: result['message'],
                      btnOkOnPress: () => Navigator.of(context).pop(),
                    ).show();
                  } else {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      title: 'Failed',
                      desc: result['message'],
                      btnOkOnPress: () {},
                    ).show();
                  }
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              Text.rich(
                style: TextStyle(color: PrimaryColor),
                TextSpan(
                  text: '© 2023 F2Tech. All rights reserved ',
                  children: [
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isStrongPassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSymbol = RegExp(r'[!@#\$&*~_.,%^]').hasMatch(password);
    return hasMinLength && hasLetter && hasNumber && hasSymbol;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#\$&*~_.,%^]').hasMatch(value)) {
      return 'Password must contain at least one symbol';
    }
    return null;
  }

  void _showDialog(String title, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      title: title,
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }
}
