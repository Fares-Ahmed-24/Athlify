import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/services/auth.dart';
import 'package:Athlify/views/auth_view/OTP.dart';
import 'package:Athlify/widget/button.dart';
import 'package:Athlify/widget/textField.dart';

class Forgetpassword extends StatelessWidget {
  Forgetpassword({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final auth = AuthService(); // Define the auth instance

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: screenHeight * 0.15,
                width: screenWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back),
                  ),
                ),
              ),
              Container(
                height: screenHeight * 0.3,
                width: screenWidth * 0.7,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    Icons.email_outlined,
                    color: Colors.grey[350],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Forget Your Password ?',
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
                  'Please enter your email address to receive a verification code.',
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Form(
                key: formkey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: emailController,
                      labelText: "Email",
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Custbutton(
                      onPressed: () async {
                        if (formkey.currentState!.validate()) {
                          final result =
                              await auth.sendOTP(emailController.text);

                          if (result['success']) {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.rightSlide,
                              title: 'Success',
                              desc: result['message'],
                              btnOkOnPress: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => OTPInputPage(
                                      email: emailController.text,
                                    ),
                                  ),
                                );
                              },
                            ).show();
                          } else {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.warning,
                              animType: AnimType.rightSlide,
                              title: 'Failed',
                              desc: result['message'],
                              btnCancelOnPress: () {},
                              btnOkOnPress: () {},
                            ).show();
                          }
                        }
                      },
                      text: "Send OTP",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
