import 'package:Athlify/services/rating%20_service.dart';
import 'package:Athlify/views/auth_view/signup.dart';
import 'package:Athlify/views/booking_view/club_details.dart';
import 'package:Athlify/views/dashboard/DashboardClubOwner&trainer/clubOwnerDashboard.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:Athlify/models/club_model.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/services/getUserType.dart';
import 'package:Athlify/services/favorite_service.dart';
import 'package:Athlify/models/favorit_model.dart';
import 'package:Athlify/models/rating_model.dart';

class ClubCardWidget extends StatefulWidget {
  final ClubModel club;
  final VoidCallback? onTapDelete;
  final VoidCallback? onTapUpdate;
  final bool showEditDeleteButtons;
  final bool fromDashboard;

  const ClubCardWidget({
    super.key,
    required this.club,
    this.onTapDelete,
    this.onTapUpdate,
    this.showEditDeleteButtons = false,
    this.fromDashboard = false,
  });

  @override
  State<ClubCardWidget> createState() => _ClubCardWidgetState();
}

class _ClubCardWidgetState extends State<ClubCardWidget> {
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
    _loadRatingData();
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
          favorite.itemId == widget.club.id.toString() &&
          favorite.itemType == 'club');
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
      itemId: widget.club.id.toString(),
      itemType: 'club',
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

  void _loadRatingData() async {
    try {
      final data =
          await RatingService.fetchAverageRating(widget.club.id.toString());
      if (mounted) {
        setState(() {
          _ratingData = data;
        });
      }
    } catch (e) {
      print('Failed to load rating data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
  if (widget.fromDashboard) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Books(clubId: widget.club.id,), // Or another dashboard screen
      ),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubDetails(
          fieldId: widget.club.id.toString(),
          rate: _ratingData?.averageRating.toString() ?? '0',
        ),
      ),
    );
  }
},

      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
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
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(23)),
                      color: Colors.grey.shade300,
                    ),
                    child: (widget.club.image ?? '').isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(23),
                            child: Image.network(
                              widget.club.image!,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 60,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.person),
                            ),
                          )
                        : Icon(Icons.person),
                  ),
                  const SizedBox(width: 16),
                  // Club info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.club.name,
                          style: TextStyle(
                            fontSize: 18,
                            color: PrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          "Location: ${widget.club.location}",
                          style:
                              const TextStyle(color: Colors.blue, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          "Price: ${widget.club.price} L.E",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          "Category: ${widget.club.clubType}",
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
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 18),
              if (widget.showEditDeleteButtons && userId == widget.club.email)
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
      ),
    );
  }
}
