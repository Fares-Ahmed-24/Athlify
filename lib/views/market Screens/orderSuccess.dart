import 'package:flutter/material.dart';

class OrderSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
              SizedBox(height: 24),
              Text(
                "Thank You!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "Your order has been placed successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff243555),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text(
                  "Back to Home",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
