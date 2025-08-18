import 'package:Athlify/views/auth_view/signup.dart';
import 'package:Athlify/views/booking_view/trainerDetails.dart';
import 'package:Athlify/views/dashboard/DashboardClubOwner&trainer/trainerDashboard.dart';
import 'package:Athlify/views/rating/rating_triner.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:Athlify/models/trainer_model.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/services/getUserType.dart';
import 'package:Athlify/services/favorite_service.dart';
import 'package:Athlify/models/favorit_model.dart';
import 'package:Athlify/services/rating%20_service.dart';
import 'package:Athlify/models/rating_model.dart';

class TrainerCardWidget extends StatefulWidget {
  final Trainer trainer;
  final VoidCallback? onTapDelete;
  final VoidCallback? onTapUpdate;
  final bool showEditDeleteButtons;
  final bool fromDashboard;

  const TrainerCardWidget({
    super.key,
    required this.trainer,
    this.onTapDelete,
    this.onTapUpdate,
    this.showEditDeleteButtons = false,
    this.fromDashboard = false,
  });

  @override
  State<TrainerCardWidget> createState() => _TrainerCardWidgetState();
}

class _TrainerCardWidgetState extends State<TrainerCardWidget> {
  final UserService _userData = UserService();
  final FavoriteService _favoriteService = FavoriteService();

  String userType = '';
  bool isFavorite = false;
  String userId = '';

  RatingResponse? _ratingData;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFavorites();
    _loadRating();
  }

  void _loadUserIdAndFavorites() async {
    String email = await _userData.getEmail();
    if (!mounted) return;

    setState(() {
      userId = email;
    });

    _checkIfFavorite();
  }

  void _checkIfFavorite() async {
    List<Favorite> favorites = await _favoriteService.getFavorites(userId);

    if (!mounted) return;
    setState(() {
      isFavorite = favorites.any((favorite) =>
          favorite.itemId == widget.trainer.id.toString() &&
          favorite.itemType == 'trainer');
    });
  }

  void _toggleFavorite() async {
    if (userId.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Authentication Required',
        desc: 'You need to sign up or log in to use favorites.',
        btnOkText: "Go to Signup",
        btnOkOnPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignupPage()),
          );
        },
      ).show();
      return;
    }

    Favorite favorite = Favorite(
      userId: userId.toString(),
      itemId: widget.trainer.id.toString(),
      itemType: 'trainer',
    );

    if (isFavorite) {
      bool success = await _favoriteService.removeFavorite(favorite);
      if (success) {
        setState(() {
          isFavorite = false;
        });
      }
    } else {
      bool success = await _favoriteService.addFavorite(favorite);
      if (success) {
        setState(() {
          isFavorite = true;
        });
      }
    }
  }

  void _loadRating() async {
    try {
      final data =
          await RatingService.fetchAverageRating(widget.trainer.id.toString());
      if (mounted) {
        setState(() {
          _ratingData = data;
        });
      }
    } catch (e) {
      print("Error loading trainer rating: $e");
    }
  }

  void _navigateToRatingPage() {
    if (userId.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Login Required',
        desc: 'You must log in to rate this trainer.',
        btnOkText: "Go to Signup",
        btnOkOnPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SignupPage()),
          );
        },
      ).show();
    } else {
      showDialog(
        context: context,
        builder: (_) => TrainerRatingDialog(
          userId: userId,
          itemId: widget.trainer.id.toString(),
          itemType: "trainer",
        ),
      ).then((_) {
        _loadRating(); // بعد ما يقفل الديالوج، يحدث التقييم
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // double averageRating = _ratingData?.averageRating ?? 0.0;
    // int totalRatings = _ratingData?.ratingCount ?? 0;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          if (widget.fromDashboard) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrainerSessions(trainerId: widget.trainer.id,), // Or another dashboard screen
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrainerDetails(
                  trainerId: widget.trainer.id,
                  rate: _ratingData?.averageRating.toString() ?? '0',
                ),
              ),
            );
          }
        },
        child:  Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: ContainerColor,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row (Image + Info + Favorite Icon)
            GestureDetector(
              onTap: _navigateToRatingPage,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        widget.trainer.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person,
                              size: 40, color: Colors.grey);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Trainer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.trainer.name,
                          style: TextStyle(
                            fontSize: 18,
                            color: PrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          "Location: ${widget.trainer.location}",
                          style:
                              const TextStyle(color: Colors.blue, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          "Price: ${widget.trainer.price} L.E",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          "Category: ${widget.trainer.category}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (_ratingData != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                "${_ratingData!.averageRating.toStringAsFixed(1)} / 5",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "(${_ratingData!.ratingCount} ratings)",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Favorite Icon
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_outline,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18),
            if (widget.showEditDeleteButtons && userId == widget.trainer.email)
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: widget.onTapUpdate,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(150, 50),
                        backgroundColor: PrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Update",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: widget.onTapDelete,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(150, 50),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      )
    );
  }
}
