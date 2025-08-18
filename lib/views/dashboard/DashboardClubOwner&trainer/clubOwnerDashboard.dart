import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constant/Constants.dart';
import '../../../functions/update_delete_club.dart';
import '../../../services/club.dart';
import '../../../services/club_bookingServices.dart';
import '../../../services/UserController.dart';
import '../../../services/trainer.dart';

import '../../../models/book_Model.dart';
import '../../../models/club_model.dart';
import '../../../models/trainer_model.dart';

class Books extends StatefulWidget {
  final String clubId;

  const Books({Key? key, required this.clubId}) : super(key: key);

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  String? _clubStatus;
  ClubModel? _club;
  late Future<List<Booking>> _futureBookings;
  final BookingService _bookingService = BookingService();

  final Map<String, Trainer> _trainerMap = {}; // trainerId → Trainer

  @override
  void initState() {
    super.initState();
    _futureBookings = _bookingService.getAllBookingsForClub(widget.clubId);
    _fetchClubDetails();
    _loadTrainers();
  }

  Future<void> _fetchClubDetails() async {
    final club = await ClubService().getClubById(widget.clubId);
    setState(() {
      _club = club;
      _clubStatus = club.clubStatue;
    });
  }

  Future<void> _loadTrainers() async {
    final bookings = await _bookingService.getAllBookingsForClub(widget.clubId);

    final trainerIds = bookings
        .map((b) => b.coachId)
        .where((id) => id != null)
        .cast<String>()
        .toSet();

    for (String id in trainerIds) {
      final trainer = await TrainerService().getTrainerById(id);
      if (trainer != null) {
        _trainerMap[id] = trainer;
      }
    }

    setState(() {});
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  String _formatTime(DateTime time) => DateFormat('HH:mm').format(time);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Bookings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Booking>>(
        future: _futureBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final bookings = snapshot.data ?? [];

          double totalRevenue = bookings.fold(0.0, (sum, b) => sum + b.price);

          double totalTrainerCost = bookings.fold(0.0, (sum, b) {
            final trainer = b.coachId != null ? _trainerMap[b.coachId!] : null;
            if (trainer != null) {
              return sum + (trainer.price * (b.duration / 60));
            }
            return sum;
          });

          double profitBeforeFees = totalRevenue - totalTrainerCost;
          double fees = profitBeforeFees * 0.03;
          double netRevenue = profitBeforeFees - fees;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 📅 Booking Table
                  if (bookings.isNotEmpty) _buildBookingsTable(bookings) else _buildEmptyMessage(),

                  const SizedBox(height: 20),

                  // 💰 Revenue Summary
                  _buildRevenueSummary(profitBeforeFees, fees, netRevenue),

                  const SizedBox(height: 20),

                  // ⚙️ Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingsTable(List<Booking> bookings) {
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
            DataColumn(label: Text('Coach')),
            DataColumn(label: Text('Net Revenue')),
            DataColumn(label: Text('Report')),
          ],
          rows: bookings.map((booking) {
            final trainer = booking.coachId != null ? _trainerMap[booking.coachId!] : null;
            double trainerCost = trainer != null ? trainer.price * (booking.duration / 60) : 0;
            double net = booking.price - trainerCost;

            return DataRow(cells: [
              DataCell(Text(booking.userEmail)),
              DataCell(Text(_formatDate(booking.date))),
              DataCell(Text(_formatTime(booking.startTime))),
              DataCell(Text(_formatTime(booking.endTime))),
              DataCell(Text('${booking.duration} min')),
              DataCell(Text(trainer?.name ?? 'N/A')),
              DataCell(Text('EGP ${net.toStringAsFixed(2)}')),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.report, color: Colors.red),
                  tooltip: 'Report this booking',
                  onPressed: () async {
                    try {
                      await UserController().reportUser(booking.userId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('✅ Report sent for ${booking.userEmail}')),
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

  Widget _buildEmptyMessage() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text("No bookings found.", style: TextStyle(fontSize: 18)),
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
          const Icon(Icons.attach_money, color: Colors.green, size: 100),
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

  Widget _summaryItem(String title, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('${value.toStringAsFixed(2)} EGP', style: const TextStyle(fontSize: 16, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStyledButton(
          _clubStatus == "available" ? "Maintenance" : "Back to Work",
          _clubStatus == "available" ? Icons.build : Icons.replay,
          _clubStatus == "available" ? SecondaryColor : Colors.green,
          () async {
            final success = _clubStatus == "available"
                ? await ClubService().setClubToMaintenance(widget.clubId)
                : await ClubService().setClubToAvailable(widget.clubId);

            if (success) {
              setState(() {
                _clubStatus = _clubStatus == "available" ? "maintenance" : "available";
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Club set to $_clubStatus")),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to update status")),
              );
            }
          },
        ),
        if (_club != null) ...[
          _buildStyledButton("Update", Icons.update, Colors.blue, () {
            showEditClubDialog(context: context, club: _club!);
          }),
          _buildStyledButton("Delete", Icons.delete, Colors.red, () {
            showDeleteConfirmationDialog(context: context, club: _club!);
          }),
        ],
      ],
    );
  }

  Widget _buildStyledButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      height: 55,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2, offset: Offset(0, 4))
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
        BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2, offset: Offset(0, 4))
      ],
    );
  }
}
