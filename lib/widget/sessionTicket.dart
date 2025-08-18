import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/club_model.dart';
import 'package:Athlify/models/trainer_model.dart';
import 'package:Athlify/services/club.dart';
import 'package:flutter/material.dart';

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = 14.0;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(20),
      ));

    final punches = Path()
      ..addOval(Rect.fromCircle(center: Offset(size.width, size.height / 2), radius: radius))
      ..addOval(Rect.fromCircle(center: Offset(size.width / 2, 0), radius: radius))
      ..addOval(Rect.fromCircle(center: Offset(size.width / 2, size.height), radius: radius));

    return Path.combine(PathOperation.difference, path, punches);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class VerticalDashDivider extends StatelessWidget {
  final double height;
  final Color color;

  const VerticalDashDivider({
    this.height = 200,
    this.color = Colors.white24,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const dashHeight = 6.0;
    const dashSpace = 4.0;
    final dashCount = (height / (dashHeight + dashSpace)).floor();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        dashCount,
            (_) => SizedBox(
          height: dashHeight,
          width: 1,
          child: DecoratedBox(decoration: BoxDecoration(color: color)),
        ),
      ),
    );
  }
}

class SessionTicketCard extends StatelessWidget {
  final DateTime date;
  final TimeOfDay startTime;
  final Duration duration;
  final TimeOfDay endTime;
  final Trainer trainer;
  final String? clubId;

  const SessionTicketCard({
    super.key,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.trainer,
    required this.endTime,
    this.clubId,
  });

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  double _calculateTotalPrice(double clubPrice, double trainerPrice) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return (trainerPrice + clubPrice) * hours +
        (trainerPrice + clubPrice) * (minutes / 60);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 375.0; // Base scale for 375px wide screen

    final sessionEndDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    final isPast = sessionEndDateTime.isBefore(DateTime.now());
    final textColor = isPast ? Colors.grey.shade400 : Colors.white;
    final backgroundColor = isPast ? Colors.grey.shade900 : SecondaryColor;
    final isAtHome = clubId == 'at_home';

    final atHomeClub = ClubModel(
      id: 'at_home',
      name: 'At Home',
      clubType: trainer.category,
      location: 'At home',
      price: 0,
      image: '',
      email: '',
      clubStatue: '',
    );

    return FutureBuilder<ClubModel?>(
      future: isAtHome ? Future.value(atHomeClub) : ClubService().getClubById(clubId!),
      builder: (context, snapshot) {
        final club = snapshot.data;
        final clubPrice = club?.price ?? 0;
        final totalPrice = _calculateTotalPrice(clubPrice.toDouble(), trainer.price.toDouble());

        return ClipPath(
          clipper: TicketClipper(),
          child: Container(
            padding: EdgeInsets.all(12 * scale),
            height: 210 * scale,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/outlined.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topRight,
              ),
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // LEFT SIDE
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        trainer.name,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '📅 ${date.toLocal().toIso8601String().split('T')[0]}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '🕒 ${_formatTime(startTime)}',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 6 * scale),
                          Icon(Icons.arrow_forward, color: textColor, size: 16 * scale),
                          SizedBox(width: 6 * scale),
                          Text(
                            _formatTime(endTime),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4 * scale),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '⏳ ${duration.inHours}h ${duration.inMinutes % 60}m',
                          style: TextStyle(color: textColor, fontSize: 14 * scale),
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      if (club != null) ...[
                        Text(
                          '🏟️ ${club.name} (${club.clubType})',
                          style: TextStyle(color: textColor, fontSize: 14 * scale),
                        ),
                        Text(
                          '📍 ${club.location}',
                          style: TextStyle(color: textColor, fontSize: 13 * scale),
                        ),
                        SizedBox(height: 6 * scale),
                      ],
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                  child: VerticalDashDivider(
                    height: 180 * scale,
                    color: textColor.withOpacity(0.3),
                  ),
                ),

                RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    '${totalPrice.toStringAsFixed(2)} EGP',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}