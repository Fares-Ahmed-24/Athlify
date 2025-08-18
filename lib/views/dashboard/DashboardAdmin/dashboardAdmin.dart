// dashboard_admin.dart
import 'package:Athlify/views/dashboard/DashboardAdmin/clubDashboardTab.dart';
import 'package:Athlify/views/dashboard/DashboardAdmin/generalDashboardTab.dart';
import 'package:Athlify/views/dashboard/DashboardAdmin/marketDashboard.dart';
import 'package:Athlify/views/dashboard/DashboardAdmin/trainerDashboardTab.dart';
import 'package:Athlify/views/dashboard/DashboardAdmin/usersDashboard.dart';
import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';

class Dashboardadmin extends StatefulWidget {
  const Dashboardadmin({super.key});

  @override
  State<Dashboardadmin> createState() => _DashboardadminState();
}

class _DashboardadminState extends State<Dashboardadmin>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
          backgroundColor: PrimaryColor,
          title: const Text(
            "Admin Dashboard",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: SecondaryContainerText,
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Clubs'),
              Tab(text: 'Trainers'),
              Tab(text: 'Users'),
              Tab(text: 'Market'),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: [
            GeneralTab(),
            ClubsDashboardTab(),
            TrainerDashboardTab(),
            UsersDashboardTab(),
            Marketdashboard(),
          ],
        ),
      ),
    );
  }
}
