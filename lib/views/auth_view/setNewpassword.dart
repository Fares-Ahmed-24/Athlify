import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:Athlify/services/auth.dart';
import 'package:Athlify/views/auth_view/signIn.dart';
import 'package:Athlify/widget/button.dart';
import 'package:Athlify/widget/passwordTf.dart';

class Newpassword extends StatefulWidget {
  final String email;

  const Newpassword({super.key, required this.email});

  @override
  State<Newpassword> createState() => _NewpasswordState();
}

class _NewpasswordState extends State<Newpassword>
    with SingleTickerProviderStateMixin {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController verfiyPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    newPasswordController.dispose();
    verfiyPasswordController.dispose();
    super.dispose();
  }

  bool isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#\$&*~_.,%^]').hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        padding: EdgeInsets.all(screenWidth * 0.03),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: screenHeight * 0.3,
                        width: screenWidth * 0.7,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Icon(
                            Icons.lock_outline,
                            color: Colors.grey[350],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    const Text(
                      'Set New Password',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      'Create a new password for your account. Make sure it\'s strong and secure.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Passwordtf(
                      labelText: 'New Password',
                      icon: Icons.lock_reset_rounded,
                      controller: newPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (!isStrongPassword(value)) {
                          return 'Password must be at least 8 characters, and include letters, numbers, and symbols.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Passwordtf(
                      labelText: 'Confirm New Password',
                      icon: Icons.verified_user_outlined,
                      controller: verfiyPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
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
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    SizedBox(
                      width: double.infinity,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Custbutton(
                              text: 'Set New Password',
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    final result =
                                        await _authService.setNewPassword(
                                      widget.email,
                                      newPasswordController.text,
                                    );

                                    if (mounted) {
                                      if (result['success']) {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.success,
                                          title: 'Success',
                                          desc: result['message'],
                                          btnOkOnPress: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Signin()),
                                            );
                                          },
                                        ).show();
                                      } else {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.error,
                                          title: 'Error',
                                          desc: result['message'],
                                          btnOkOnPress: () {},
                                        ).show();
                                      }
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.error,
                                        title: 'Oops!',
                                        desc:
                                            'Something went wrong. Please try again.',
                                        btnOkOnPress: () {},
                                      ).show();
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                }
                              },
                            ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
