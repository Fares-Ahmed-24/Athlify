import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';

class Details extends StatelessWidget {
  final String label;
  final String status;
  final double rating;
  final String? bio;
  final int? experienceYears;
  final void Function()? onRate;

  const Details({
    Key? key,
    required this.label,
    required this.status,
    required this.rating,
    this.bio,
    this.experienceYears,
    this.onRate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final titleStyle = TextStyle(
      fontSize: screenWidth * 0.045,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    final labelStyle = TextStyle(
      fontSize: screenWidth * 0.04,
      fontWeight: FontWeight.w500,
      color: Colors.grey[800],
    );

    final valueStyle = TextStyle(
      fontSize: screenWidth * 0.04,
      color: Colors.black87,
    );

    final iconSize = screenWidth * 0.06;

    Widget sectionTitle(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 18.0),
      child: Text(text, style: titleStyle),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Label
          Row(
            children: [
              Icon(Icons.category, color: PrimaryColor, size: iconSize),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: titleStyle)),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(),

          /// Status
          sectionTitle("Status"),
          Row(
            children: [
              Icon(
                status.toLowerCase().contains("available")
                    ? Icons.check_circle
                    : Icons.cancel,
                color: status.toLowerCase().contains("available")
                    ? Colors.green
                    : Colors.red,
                size: iconSize,
              ),
              const SizedBox(width: 10),
              Text(status, style: valueStyle),
            ],
          ),

          /// Experience
          if (experienceYears != null) ...[
            sectionTitle("Experience"),
            Row(
              children: [
                Icon(Icons.school, color: Colors.deepPurple, size: iconSize),
                const SizedBox(width: 10),
                Text("$experienceYears years", style: valueStyle),
              ],
            ),
          ],

          /// Bio
          if (bio != null && bio!.trim().isNotEmpty) ...[
            sectionTitle("About"),
            Text(
              bio!,
              style: valueStyle,
              textAlign: TextAlign.justify,
            ),
          ],

          sectionTitle("Rating"),
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < rating.round()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.orange,
                  size: iconSize * 1.1,
                );
              }),
              const Spacer(),
              if (onRate != null)
                TextButton.icon(
                  onPressed: onRate,
                  icon: Icon(Icons.edit, size: iconSize * 0.9, color: PrimaryColor),
                  label: Text(
                    "Rate",
                    style: labelStyle.copyWith(color: PrimaryColor),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}