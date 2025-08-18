import 'package:Athlify/services/admin_notify.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:Athlify/services/auth.dart';
import 'package:Athlify/views/Home.dart';
import 'package:Athlify/views/auth_view/forgetPassword.dart';
import 'package:Athlify/views/auth_view/signup.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/widget/textField.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signin extends StatefulWidget {
  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey();

  final auth = AuthService();
  bool _passwordVisible = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  backgroundColor: Color(0XffE9E9E9),
                  child: IconButton(
                      color: PrimaryColor,
                      onPressed: Navigator.of(context).pop,
                      icon: Icon(Icons.arrow_back)),
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back",
                        style: TextStyle(
                            color: PrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 28),
                      ),
                      Text(
                          "Enter your Email and Password to access your account")
                    ],
                  )),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Form(
                    key: formkey,
                    child: Column(
                      children: [
                        CustomTextFormField(
                          controller: emailController,
                          labelText: "Email",
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        CustomTextFormField(
                          controller: passwordController,
                          suffixIcon: IconButton(
                            icon: Icon(_passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(
                                () {
                                  _passwordVisible = !_passwordVisible;
                                },
                              );
                            },
                          ),
                          labelText: "Password",
                          prefixIcon: Icons.lock_outline,
                          obscureText: _passwordVisible,
                        ),
                      ],
                    )),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Forgetpassword()));
                    },
                    child: Text(
                      "Forget Password?",
                      style: TextStyle(
                          color: SecondaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (formkey.currentState!.validate()) {
                          setState(() => _isLoading = true);

                          final result = await auth.login(
                              emailController.text, passwordController.text);

                          if (result['success']) {
                            final prefs = await SharedPreferences.getInstance();
                            final userType = prefs.getString('userType');
                            print(userType);
                            if (userType == "admin") {
                              await NotificationService.initNotifications();
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message']),
                                backgroundColor: Colors.green,
                              ),
                            );

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()),
                              (Route<dynamic> route) => false,
                            );
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

                          setState(() => _isLoading = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PrimaryColor,
                  fixedSize: Size(380, 60),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "Sign in",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              SizedBox(
                height: 20,
              ),
              Align(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account ",
                      style: TextStyle(fontSize: 18),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupPage()));
                      },
                      child: Text(
                        "SignUp?",
                        style: TextStyle(
                            color: SecondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
