import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/Constants.dart';
import '../../models/club_model.dart';
import '../../models/trainer_model.dart';
import '../../services/club.dart';
import '../../services/club_bookingServices.dart';
import '../../widget/sessionTicket.dart';

class SessionConfirmation extends StatefulWidget {
  final DateTime startTime;
  final DateTime date;
  final Duration duration;
  final String? clubId;
  final Trainer trainer;

  const SessionConfirmation({
    Key? key,
    this.clubId,
    required this.trainer,
    required this.startTime,
    required this.duration,
    required this.date,
  }) : super(key: key);

  @override
  State<SessionConfirmation> createState() => _SessionConfirmationState();
}

class _SessionConfirmationState extends State<SessionConfirmation> {
  bool isLoading = false;
  ClubModel? club;
  bool isClubLoading = true;

  late final DateTime endTime = widget.startTime.add(widget.duration);

  @override
  void initState() {
    super.initState();
    _loadClub();
  }

  void _loadClub() async {
    if (widget.clubId != null) {
      club = await ClubService().getClubById(widget.clubId!);
    }
    setState(() {
      isClubLoading = false;
    });
  }

  double _calculateTotalPrice(double clubPrice, double trainerPrice) {
    final hours = widget.duration.inHours;
    final minutes = widget.duration.inMinutes % 60;
    return (trainerPrice + clubPrice) * hours +
        (trainerPrice + clubPrice) * (minutes / 60);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final spacing = screenHeight * 0.02;
    final padding = screenWidth * 0.05;
    final fontSize = screenWidth * 0.045;
    final buttonHeight = screenHeight * 0.065;

    final clubPrice = club?.price.toDouble() ?? 0.0;
    final totalPrice =
    _calculateTotalPrice(clubPrice, widget.trainer.price.toDouble());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: spacing),

              /// Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              SizedBox(height: spacing * 0.5),

              /// Session Ticket
              isClubLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SessionTicketCard(
                date: widget.date,
                startTime: TimeOfDay(
                  hour: widget.startTime.hour,
                  minute: widget.startTime.minute,
                ),
                duration: widget.duration,
                endTime: TimeOfDay(
                  hour: endTime.hour,
                  minute: endTime.minute,
                ),
                trainer: widget.trainer,
                clubId: widget.clubId ?? 'at_home',
              ),

              SizedBox(height: spacing * 2),

              /// Confirm Button
              SizedBox(
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    setState(() => isLoading = true);
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getString('userId') ?? '';
                      final email = prefs.getString('email') ?? '';

                      if (userId.isEmpty) {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: 'Error',
                          desc: 'User not logged in.',
                          btnOkOnPress: () {},
                        ).show();
                        setState(() => isLoading = false);
                        return;
                      }

                      final formattedDate =
                          "${widget.date.year.toString().padLeft(4, '0')}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}";

                      await BookingService().createBooking(
                        userEmail: email,
                        userId: userId,
                        fieldId: widget.clubId ?? 'at_home',
                        coachId: widget.trainer.id,
                        date: formattedDate,
                        startTime: widget.startTime.toIso8601String(),
                        endTime: endTime.toIso8601String(),
                        duration: widget.duration.inMinutes,
                        price: totalPrice.toInt(),
                      );

                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.success,
                        animType: AnimType.rightSlide,
                        title: 'Session Booked!',
                        desc: 'Your session was successfully booked.',
                        btnOkOnPress: () => Navigator.of(context).pop(),
                      ).show();
                    } catch (e) {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Booking Failed',
                        desc: e.toString(),
                        btnOkOnPress: () {},
                      ).show();
                    } finally {
                      setState(() => isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : Text(
                    'Confirm Session',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: spacing * 2),
            ],
          ),
        ),
      ),
    );
  }
}
