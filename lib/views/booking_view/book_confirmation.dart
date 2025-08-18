import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/trainer_model.dart';
import 'package:Athlify/services/club_bookingServices.dart';
import 'package:Athlify/views/bottom_nav_view/recent.dart';
import 'package:Athlify/widget/clubTicket.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:Athlify/models/club_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookConfirmation extends StatefulWidget {
  final DateTime startTime;
  final DateTime date;
  final Duration duration;
  final ClubModel club;
  final Trainer? trainer;

  const BookConfirmation({
    Key? key,
    this.trainer,
    required this.startTime,
    required this.duration,
    required this.club,
    required this.date,
  }) : super(key: key);

  @override
  State<BookConfirmation> createState() => _BookConfirmationState();
}

class _BookConfirmationState extends State<BookConfirmation> {
  late DateTime endTime = widget.startTime.add(widget.duration);
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final padding = screenWidth * 0.05;
    final spacing = screenHeight * 0.02;
    final buttonHeight = screenHeight * 0.065;
    final fontSize = screenWidth * 0.045;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding),
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

              /// Ticket
              TicketCard(
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
                club: widget.club,
              ),

              SizedBox(height: spacing * 3),

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
                      final userEmail = prefs.getString('email') ?? '';

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

                      final booking = await BookingService().createBooking(
                        userEmail: userEmail,
                        userId: userId,
                        fieldId: widget.club.id.toString(),
                        date: formattedDate,
                        startTime: widget.startTime.toIso8601String(),
                        endTime: endTime.toIso8601String(),
                        duration: widget.duration.inMinutes,
                        price: widget.club.price * widget.duration.inHours,
                      );

                      setState(() {
                        RecentBook(); // optional
                      });

                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.success,
                        animType: AnimType.rightSlide,
                        title: 'Booking Confirmed!',
                        desc: 'Your booking was successful.',
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
                    'Confirm Booking',
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
