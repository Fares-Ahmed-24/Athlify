import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';

class Customelisttile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final VoidCallback onTap;

  const Customelisttile(
      {super.key,
      required this.leadingIcon,
      required this.title,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: PrimaryColor,
        child: Icon(
          leadingIcon,
          size: 28,
          color: Colors.white,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
    );
  }
}
