import 'package:Athlify/views/booking_view/session.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/trainer_model.dart';
import 'package:Athlify/views/auth_view/signup.dart';
import 'package:Athlify/views/rating/rating_clubs.dart';
import 'package:Athlify/widget/details.dart';
import 'package:Athlify/widget/imageCard.dart';

import '../../services/trainer.dart';

class TrainerDetails extends StatelessWidget {
  final String trainerId;
  final String rate;

  const TrainerDetails({
    Key? key,
    required this.trainerId,
    required this.rate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<Trainer?>(
      future: TrainerService().getTrainerById(trainerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Failed to load trainer profile')),
          );
        }

        final trainer = snapshot.data!;

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                // Top image card
                ImageCard(
                  imageUrl: trainer.image,
                  price: trainer.price,
                  location: trainer.location,
                  title: trainer.name,
                  itemId: trainer.id,
                  itemType: 'trainer',
                ),

                // Details Card
                Details(
                  bio: trainer.bio,
                  experienceYears: trainer.experienceYears,
                  label: trainer.category,
                  status: trainer.isAvailable ? "Available" : "Not Available",
                  rating: rate == '0' ? 0.0 : double.tryParse(rate) ?? 0.0,
                  onRate: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String userId = prefs.getString('userId') ?? '';
                    if (userId.isNotEmpty) {
                      showClubRatingDialog(
                        context: context,
                        userId: userId,
                        itemId: trainer.id,
                        itemType: "trainer",
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
                            MaterialPageRoute(builder: (_) => SignupPage()),
                          );
                        },
                      ).show();
                    }
                  },
                ),

                // Gallery
                if (trainer.gallery != null && trainer.gallery!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Gallery",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: trainer.gallery!.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: InteractiveViewer(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              trainer.gallery![index],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      trainer.gallery![index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Book Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    sessionBook(
                              trainer: trainer,
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(
                                  position: offsetAnimation, child: child);
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
                      child: const Text(
                        "Book Session",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}
