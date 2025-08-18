import 'package:flutter/material.dart';

void navigateWithSlide(BuildContext context, Widget page) {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0), // from right to left
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    ),
  );
}
