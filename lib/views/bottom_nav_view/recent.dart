import 'package:Athlify/models/book_Model.dart';
import 'package:Athlify/models/club_model.dart';
import 'package:Athlify/models/trainer_model.dart';
import 'package:Athlify/services/club.dart';
import 'package:Athlify/services/club_bookingServices.dart';
import 'package:Athlify/services/trainer.dart';
import 'package:Athlify/widget/clubTicket.dart';
import 'package:Athlify/widget/sessionTicket.dart'; // make sure this is imported
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentBook extends StatefulWidget {
  const RecentBook({Key? key}) : super(key: key);

  @override
  State<RecentBook> createState() => _RecentBookState();
}

class _RecentBookState extends State<RecentBook> {
  final BookingService bookingService = BookingService();
  late Future<Map<String, dynamic>?> _futureNearestBooking;

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>?> _loadNearestBooking() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? '';

      Booking? nextBooking =
          await bookingService.getNearestBookingByUser(userId);

      if (nextBooking == null || nextBooking.startTime.isBefore(DateTime.now()))
        return null;

      // Determine if it's a session (has coachId) or field booking
      bool isSession = nextBooking.coachId != null;

      final extra = isSession
          ? await TrainerService().getTrainerById(nextBooking.coachId!)
          : await ClubService().getClubById(nextBooking.fieldId ?? 'at_home');

      return {
        'booking': nextBooking,
        'isSession': isSession,
        'extra': extra,
      };
    } catch (e) {
      throw Exception('Error loading nearest booking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadNearestBooking(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text(''));
        }

        final booking = snapshot.data!['booking'] as Booking;
        final isSession = snapshot.data!['isSession'] as bool;

        TimeOfDay startTime = TimeOfDay.fromDateTime(booking.startTime);
        TimeOfDay endTime = TimeOfDay.fromDateTime(booking.endTime);
        double hoursDouble = booking.duration / 60;
        Duration duration = Duration(
          hours: hoursDouble.floor(),
          minutes: ((hoursDouble % 1) * 60).round(),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "UPCOMING!",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            isSession
                ? SessionTicketCard(
                    startTime: startTime,
                    endTime: endTime,
                    date: booking.date,
                    duration: duration,
                    trainer: snapshot.data!['extra'] as Trainer,
                    clubId: booking.fieldId,
                  )
                : TicketCard(
                    startTime: startTime,
                    endTime: endTime,
                    date: booking.date,
                    duration: duration,
                    club: snapshot.data!['extra'] as ClubModel,
                  ),
          ],
        );
      },
    );
  }
}
