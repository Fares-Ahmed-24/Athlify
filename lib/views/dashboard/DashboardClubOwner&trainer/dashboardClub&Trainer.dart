import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/functions/update_delete_club.dart';
import 'package:Athlify/functions/update_delete_trainerCard.dart';
import 'package:Athlify/models/club_model.dart';
import 'package:Athlify/models/trainer_model.dart';
import 'package:Athlify/services/club.dart';
import 'package:Athlify/services/trainer.dart';
import 'package:Athlify/widget/clubcard.dart';
import 'package:Athlify/widget/trainercard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardClubTrainer extends StatefulWidget {
  @override
  State<DashboardClubTrainer> createState() => _DashboardClubTrainerState();
}

class _DashboardClubTrainerState extends State<DashboardClubTrainer> {
  String? userEmail;
  String? userType;
  List<ClubModel> userClubs = [];
  List<Trainer> userTrainers = [];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final type = prefs.getString('userType');

    if (email != null && type != null) {
      setState(() {
        userEmail = email;
        userType = type;
      });

      _fetchDataBasedOnUserType(email, type);
    }
  }

  void _fetchDataBasedOnUserType(String email, String type) async {
    if (type == 'clubowner') {
      final clubResponse = await ClubService().getClubsByEmail(email);
      setState(() {
        userClubs = clubResponse;
      });
    } else if (type == 'trainer') {
      final trainerResponse = await TrainerService().getTrainerByEmail(email);
      setState(() {
        userTrainers = trainerResponse;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColor,
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userType == 'clubowner') ...[
                const Text("Clubs",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ...userClubs.map((club) => ClubCardWidget(
                    club: club,
                    showEditDeleteButtons: true,
                    onTapUpdate: () =>
                        showEditClubDialog(context: context, club: club),
                    onTapDelete: () => showDeleteConfirmationDialog(
                        context: context, club: club))),
              ],
              if (userType == 'trainer') ...[
                const Text("Trainers",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ...userTrainers.map((trainer) => TrainerCardWidget(
                      trainer: trainer,
                      showEditDeleteButtons: true,
                      onTapUpdate: () => showEditTrainerDialog(
                          context: context, trainer: trainer),
                      onTapDelete: () => showDeleteConfirmationDialogTrainer(
                          context: context, trainer: trainer),
                    )),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
