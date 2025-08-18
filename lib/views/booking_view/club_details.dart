import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/club_model.dart';
import 'package:Athlify/services/club.dart';
import 'package:Athlify/views/auth_view/signup.dart';
import 'package:Athlify/views/booking_view/date_timePicker.dart';
import 'package:Athlify/views/rating/rating_clubs.dart';
import 'package:Athlify/widget/details.dart';
import 'package:Athlify/widget/imageCard.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClubDetails extends StatelessWidget {
  final String fieldId;
  final String rate;

  ClubDetails({Key? key, required this.fieldId, required this.rate})
      : super(key: key);

  late final Future<ClubModel?> _clubFuture = ClubService().getClubById(fieldId);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;
    final verticalSpacing = screenWidth * 0.04;
    final fontSize = screenWidth * 0.045;

    return FutureBuilder<ClubModel?>(
      future: ClubService().getClubById(fieldId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Failed to load club details')),
          );
        }

        final club = snapshot.data!;

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: verticalSpacing),

                // Top image card
                ImageCard(
                  imageUrl: club.image ?? '',
                  price: club.price,
                  location: club.location,
                  title: club.name,
                  itemId: club.id,
                  itemType: 'club',
                ),


                // Details Card
                Details(
                  label: club.clubType,
                  status: club.clubStatue,
                  rating: rate == '0' ? 0.0 : double.tryParse(rate) ?? 0.0,
                  onRate: () async {
                    SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    String userId = prefs.getString('userId') ?? '';
                    if (userId.isNotEmpty) {
                      showClubRatingDialog(
                        context: context,
                        userId: userId,
                        itemId: club.id,
                        itemType: "club",
                      );
                    } else {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        animType: AnimType.bottomSlide,
                        title: 'Login Required',
                        desc: 'You need to log in before rating.',
                        btnOkText: "Go to Signup",
                        btnOkOnPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => SignupPage()),
                          );
                        },
                      ).show();
                    }
                  },
                ),

                SizedBox(height: verticalSpacing * 1.5),

                // Book Button or Maintenance Message
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: SizedBox(
                    width: double.infinity,
                    child: club.clubStatue.toLowerCase() == 'available'
                        ? ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation,
                                secondaryAnimation) =>
                                Book(club: club),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                            transitionDuration:
                            const Duration(milliseconds: 800),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: Text(
                        "Book Game",
                        style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                        : Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Under Maintenance',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize * 0.95,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: verticalSpacing * 2),
              ],
            ),
          ),
        );
      },
    );
  }
}