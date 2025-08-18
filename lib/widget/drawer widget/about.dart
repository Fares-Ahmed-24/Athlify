import 'package:flutter/material.dart';

void showAboutAthlifyDialog(BuildContext context) {
  showAboutDialog(
    context: context,
    applicationIcon: Image.asset(
      "assets/Logo without background.png",
      width: 80,
      height: 80,
    ),
    applicationName: 'About Athlify',
    applicationVersion: '0.0.1',
    applicationLegalese: 'Developed by AthlifyTeam',
    children: const <Widget>[
      Text(
        'Athlify is a mobile platform that helps users reserve sports fields, book personal trainers, and shop for high-quality sports supplements — all in one place.',
        textAlign: TextAlign.left,
      ),
      SizedBox(height: 8),
      Text(
        '🏟 Features include:\n• Field reservation\n• Sports supplement marketplace\n• Personal trainer booking',
        textAlign: TextAlign.left,
      ),
      SizedBox(height: 8),
      Text(
        '🛒 The in-app market offers a wide range of trusted supplements to support athletes in achieving their fitness goals.',
        textAlign: TextAlign.left,
      ),
      SizedBox(height: 8),
      Text(
        '🌐 Built using Flutter and Node.js — Athlify ensures a secure, fast, and user-friendly experience for athletes everywhere.',
        textAlign: TextAlign.left,
      ),
    ],
  );
}
