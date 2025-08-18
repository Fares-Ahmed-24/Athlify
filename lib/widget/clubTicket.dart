import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/club_model.dart';
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
      ..addOval(Rect.fromCircle(
          center: Offset(size.width, size.height / 2), radius: radius))
      ..addOval(
          Rect.fromCircle(center: Offset(size.width / 2, 0), radius: radius))
      ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height), radius: radius));

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

class TicketCard extends StatelessWidget {
  final DateTime date;
  final TimeOfDay startTime;
  final Duration duration;
  final TimeOfDay endTime;
  final ClubModel club;

  const TicketCard({
    super.key,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.club,
    required this.endTime,
  });

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isSmallScreen = screenWidth < 350;
    final isPast = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    ).isBefore(DateTime.now());

    final textColor = isPast ? Colors.grey.shade400 : Colors.white;
    final backgroundColor = isPast ? Colors.grey.shade900 : SecondaryColor;

    final fontScale = screenWidth / 400.0;
    final contentFont = (double size) => size * fontScale;

    return ClipPath(
      clipper: TicketClipper(),
      child: Container(
        padding: const EdgeInsets.all(12),
        height: isSmallScreen ? 180 : 210,
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
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      club.name,
                      style: TextStyle(
                        color: textColor,
                        fontSize: contentFont(24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '📅 ${date.toLocal().toIso8601String().split('T')[0]}',
                          style: TextStyle(
                            color: textColor,
                            fontSize: contentFont(14),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🕒 ${_formatTime(startTime)}',
                              style: TextStyle(
                                color: textColor,
                                fontSize: contentFont(18),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.arrow_forward,
                                color: textColor, size: contentFont(16)),
                            const SizedBox(width: 6),
                            Text(
                              _formatTime(endTime),
                              style: TextStyle(
                                color: textColor,
                                fontSize: contentFont(18),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '⏳ ${duration.inHours}h ${duration.inMinutes % 60}m',
                          style: TextStyle(
                            color: textColor,
                            fontSize: contentFont(13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '🏟️ ${club.clubType}',
                      style: TextStyle(color: textColor, fontSize: contentFont(14)),
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '📍 ${club.location}',
                      style: TextStyle(color: textColor, fontSize: contentFont(14)),
                    ),
                  ),
                ],
              ),
            ),

            // DIVIDER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: VerticalDashDivider(
                height: isSmallScreen ? 180 : 210,
                color: textColor.withOpacity(0.3),
              ),
            ),

            // PRICE
            RotatedBox(
              quarterTurns: 3,
              child: Text(
                '${(club.price * duration.inHours + club.price * (duration.inMinutes % 60) / 60).toStringAsFixed(2)} EGP',
                style: TextStyle(
                  color: textColor,
                  fontSize: contentFont(18),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
