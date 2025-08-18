import 'package:Athlify/views/dashboard/DashboardAdmin/DashboardPieChart.dart';
import 'package:flutter/material.dart';

class GeneralTab extends StatelessWidget {
  const GeneralTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: EdgeInsets.all(16),
      child: DashboardAnalyticsCard(),
    );
  }
}
