import 'package:flutter/material.dart';
import 'package:Athlify/models/club_model.dart';
import 'package:Athlify/services/club.dart';
import 'package:Athlify/functions/update_delete_club.dart';
import 'package:Athlify/widget/clubcard.dart';

class ClubsDashboardTab extends StatefulWidget {
  const ClubsDashboardTab({super.key});

  @override
  State<ClubsDashboardTab> createState() => _ClubsDashboardTab();
}

class _ClubsDashboardTab extends State<ClubsDashboardTab> {
  List<ClubModel> allClubs = [];

  @override
  void initState() {
    super.initState();
    _fetchAllClubs();
  }

  void _fetchAllClubs() async {
    try {
      final response = await ClubService().getClubs();
      setState(() => allClubs = response);
    } catch (e) {
      print("Error fetching clubs: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Clubs",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ...allClubs.map((club) => ClubCardWidget(
                fromDashboard: true,
                club: club,
                showEditDeleteButtons: true,
                onTapUpdate: () =>
                    showEditClubDialog(context: context, club: club),
                onTapDelete: () =>
                    showDeleteConfirmationDialog(context: context, club: club),
              )),
        ],
      ),
    );
  }
}
