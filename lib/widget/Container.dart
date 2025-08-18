import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';

class CustomContainer extends StatelessWidget {
  final String imagePath;
  final String buttonText;

  CustomContainer({required this.imagePath, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 380,
        height: 65,
        decoration: BoxDecoration(
          color: ContainerColor,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Container(
                height: 35,
                child: Image.asset(imagePath),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Text(
                buttonText,
                style: TextStyle(
                  color: SecondaryContainerText,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
