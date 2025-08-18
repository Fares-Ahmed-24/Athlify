import 'package:Athlify/views/Home.dart';
import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/views/auth_view/signIn.dart';
import 'package:Athlify/views/auth_view/signup.dart';

class Or extends StatelessWidget {
  const Or({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      // iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16.0 : 32.0,
            vertical: 16.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Image.asset(
                    "assets/image.png",
                    width: isSmallScreen ? 180 : 230,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    "Athlify",
                    style: TextStyle(
                      fontFamily: "Nasalization",
                      fontSize: isSmallScreen ? 48 : 62,
                      color: PrimaryColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    "Welcome! Sign in or create an account to continue.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SecondaryContainerText,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 15,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: isSmallScreen ? 65 : 75,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Signin()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 22 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  SizedBox(
                    width: double.infinity,
                    height: isSmallScreen ? 65 : 75,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: PrimaryColor, width: 2),
                        ),
                      ),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: PrimaryColor,
                          fontSize: isSmallScreen ? 22 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Align(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Continue as ",
                          style: TextStyle(fontSize: 18),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()));
                          },
                          child: Text(
                            "Guest?",
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
            ],
          ),
        ),
      ),
    );
  }
}
