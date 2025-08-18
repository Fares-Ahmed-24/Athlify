// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:Athlify/models/book_Model.dart';
import 'package:Athlify/models/club_model.dart';
import 'package:Athlify/models/trainer_model.dart';

import 'package:Athlify/services/UserController.dart';
import 'package:Athlify/services/club.dart';
import 'package:Athlify/services/club_bookingServices.dart';
import 'package:Athlify/services/trainer.dart';
import 'package:Athlify/functions/update_delete_trainerCard.dart';

class TrainerSessions extends StatefulWidget {
  final String trainerId;

  const TrainerSessions({Key? key, required this.trainerId}) : super(key: key);

  @override
  State<TrainerSessions> createState() => _TrainerSessionsState();
}

class _TrainerSessionsState extends State<TrainerSessions> {
  Trainer? _trainer;
  Map<String, ClubModel> _clubMap = {};
  bool _clubsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadTrainer();
  }

  void _loadTrainer() async {
    final trainer = await TrainerService().getTrainerById(widget.trainerId);
    setState(() => _trainer = trainer);
  }

  @override
  void didUpdateWidget(covariant TrainerSessions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trainerId != widget.trainerId) {
      _clubsLoaded = false;
      _clubMap.clear();
    }
  }

  Future<void> _loadClubs(List<Booking> bookings) async {
    final fieldIds = bookings.map((b) => b.fieldId).whereType<String>().toSet();
    final Map<String, ClubModel> tempMap = {};

    for (String id in fieldIds) {
      try {
        final club = await ClubService().getClubById(id);
        if (club != null) tempMap[id] = club;
      } catch (e) {
        debugPrint('Error fetching club with id $id: $e');
      }
    }

    setState(() {
      _clubMap = tempMap;
      _clubsLoaded = true;
    });
  }

  String formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  String formatTime(DateTime time) => DateFormat('HH:mm').format(time);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Sessions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Booking>>(
        future: BookingService().getAllBookingsForTrainer(widget.trainerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final sessions = snapshot.data ?? [];

          if (!_clubsLoaded && sessions.isNotEmpty) {
            _loadClubs(sessions);
          }

          double totalRevenue = sessions.fold(0.0, (sum, s) => sum + s.price);

          double totalFieldCost = sessions.fold(0.0, (sum, s) {
            final club = s.fieldId != null ? _clubMap[s.fieldId!] : null;
            return club != null ? sum + (club.price * (s.duration / 60)) : sum;
          });

          double fees = totalRevenue * 0.03;
          double netRevenue = totalRevenue - totalFieldCost - fees;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 📅 Sessions Table
                if (sessions.isNotEmpty)
                  _buildSessionsTable(sessions)
                else
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("No sessions found.",
                        style: TextStyle(fontSize: 18)),
                  ),

                const SizedBox(height: 20),

                // 💰 Revenue Summary
                _buildRevenueSummary(totalRevenue, fees, netRevenue),

                const SizedBox(height: 20),

                // 🛠️ Action Buttons
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionsTable(List<Booking> sessions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('User Email')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Start Time')),
            DataColumn(label: Text('End Time')),
            DataColumn(label: Text('Duration')),
            DataColumn(label: Text('Field')),
            DataColumn(label: Text('Net Revenue')),
            DataColumn(label: Text('Report')),
          ],
          rows: sessions.map((s) {
            final club = s.fieldId != null ? _clubMap[s.fieldId!] : null;
            double fieldCost =
                club != null ? club.price * (s.duration / 60) : 0;
            double net = s.price - fieldCost;

            return DataRow(cells: [
              DataCell(Text(s.userEmail)),
              DataCell(Text(formatDate(s.date))),
              DataCell(Text(formatTime(s.startTime))),
              DataCell(Text(formatTime(s.endTime))),
              DataCell(Text('${s.duration} min')),
              DataCell(Text(club?.name ?? 'N/A')),
              DataCell(Text('EGP ${net.toStringAsFixed(2)}')),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.report, color: Colors.red),
                  tooltip: 'Report this booking',
                  onPressed: () async {
                    try {
                      await UserController().reportUser(s.userId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('✅ Report sent for ${s.userEmail}')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Failed to report user: $e')),
                      );
                    }
                  },
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRevenueSummary(double revenue, double fees, double net) {
    return Container(
      height: 210,
      width: double.infinity,
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: const Icon(Icons.attach_money, color: Colors.green, size: 100)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryItem("Total Revenue", revenue),
                _summaryItem("Fees (3%)", fees),
                _summaryItem("Net Revenue", net),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('${value.toStringAsFixed(2)} EGP',
              style: const TextStyle(fontSize: 16, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStyledButton(
          _trainer!.isAvailable ? "Take a Break" : "Resume Availability",
          _trainer!.isAvailable
              ? Icons.pause_circle_filled
              : Icons.play_circle_fill,
          Colors.white,
          () async {
            bool success;
            if (_trainer!.isAvailable) {
              success =
                  await TrainerService().makeTrainerUnavailable(_trainer!.id);
            } else {
              success =
                  await TrainerService().makeTrainerAvailable(_trainer!.id);
            }

            if (success) {
              setState(() {
                _trainer = Trainer(
                  id: _trainer!.id,
                  name: _trainer!.name,
                  isAvailable: !_trainer!.isAvailable,
                  email: _trainer!.email,
                  image: _trainer!.image,
                  price: _trainer!.price,
                  category: _trainer!.category,
                  phone: _trainer!.phone,
                  location: _trainer!.location,
                  // carry over other fields as needed
                );
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                  _trainer!.isAvailable
                      ? "✅ Trainer is now available"
                      : "⏸️ Trainer is now unavailable",
                )),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("❌ Failed to change availability status")),
              );
            }
          },
          _trainer!.isAvailable ? Colors.orange : Colors.green,
        ),
        if (_trainer != null) ...[
          _buildStyledButton(
            "Update",
            Icons.update,
            Colors.white,
            () => showEditTrainerDialog(context: context, trainer: _trainer!),
            Colors.blue,
          ),
          _buildStyledButton(
            "Delete",
            Icons.delete,
            Colors.white,
            () => showDeleteConfirmationDialogTrainer(
                context: context, trainer: _trainer!),
            Colors.red,
          ),
        ]
      ],
    );
  }

  Widget _buildStyledButton(String text, IconData icon, Color iconColor,
      VoidCallback onTap, Color bgColor) {
    return Container(
      height: 55,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4))
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Text(text,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [
        BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4)),
      ],
    );
  }
}
