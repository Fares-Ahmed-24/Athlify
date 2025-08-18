import 'package:flutter/material.dart';
import 'package:Athlify/models/trainer_model.dart';
import 'package:Athlify/services/trainer.dart';
import 'package:Athlify/functions/update_delete_trainerCard.dart';
import 'package:Athlify/widget/trainercard.dart';

class TrainerDashboardTab extends StatefulWidget {
  const TrainerDashboardTab({super.key});

  @override
  State<TrainerDashboardTab> createState() => _TrainerDashboardTab();
}

class _TrainerDashboardTab extends State<TrainerDashboardTab> {
  List<Trainer> allTrainers = [];

  @override
  void initState() {
    super.initState();
    _fetchAllTrainers();
  }

  void _fetchAllTrainers() async {
    try {
      final response = await TrainerService().getTrainers();
      setState(() => allTrainers = response);
    } catch (e) {
      print("Error fetching trainers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Trainers",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ...allTrainers.map((trainer) => TrainerCardWidget(
            fromDashboard: true,
                trainer: trainer,
                showEditDeleteButtons: true,
                onTapUpdate: () =>
                    showEditTrainerDialog(context: context, trainer: trainer),
                onTapDelete: () => showDeleteConfirmationDialogTrainer(
                    context: context, trainer: trainer),
              )),
        ],
      ),
    );
  }
}
