import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/views/auth_view/signIn.dart';
import 'package:Athlify/views/auth_view/signup.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key, required String imagePath, required String title, required String subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Image.asset(
                "assets/Logo without background.png",
                width: 230,
              ),
              Text(
                "Athlify",
                style: TextStyle(
                    fontFamily: "Nasalization",
                    fontSize: 62,
                    color: PrimaryColor),
              ),
              Text(
                "Welcome! Sign in or create an account to continue.",
                style: TextStyle(
                    color: SecondaryContainerText,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return Signin();
                    }));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: PrimaryColor, fixedSize: Size(385, 77)),
                  child: Text(
                    "SignIn",
                    style: TextStyle(color: Colors.white, fontSize: 26),
                  ),
                ),
                SizedBox(
                  height: 18,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return SignupPage();
                    }));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      fixedSize: Size(385, 77),
                      side: const BorderSide(color: PrimaryColor, width: 3)),
                  child: Text(
                    "SignUp",
                    style: TextStyle(color: PrimaryColor, fontSize: 26),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
