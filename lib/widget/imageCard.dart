import 'package:flutter/material.dart';
import 'package:Athlify/models/favorit_model.dart';
import 'package:Athlify/services/favorite_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:Athlify/views/auth_view/signup.dart';
import 'package:Athlify/services/getUserType.dart';

class ImageCard extends StatefulWidget {
  final String imageUrl;
  final int price;
  final String location;
  final String title;
  final String itemId; // clubId or trainerId
  final String itemType; // "club" or "trainer"

  const ImageCard({
    Key? key,
    required this.imageUrl,
    required this.price,
    required this.location,
    required this.title,
    required this.itemId,
    required this.itemType,
  }) : super(key: key);

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  bool isFavorite = false;
  String userId = '';
  final FavoriteService _favoriteService = FavoriteService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUserAndFavorites();
  }

  void _loadUserAndFavorites() async {
    String email = await _userService.getEmail();
    if (!mounted) return;

    setState(() => userId = email);
    _checkIfFavorite();
  }

  void _checkIfFavorite() async {
    List<Favorite> favorites = await _favoriteService.getFavorites(userId);
    if (!mounted) return;

    setState(() {
      isFavorite = favorites.any((fav) =>
      fav.itemId == widget.itemId &&
          fav.itemType.toLowerCase() == widget.itemType.toLowerCase());
    });
  }

  void _toggleFavorite() async {
    if (userId.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Authentication Required',
        desc: 'You need to log in or sign up to use favorites.',
        btnOkText: "Go to Signup",
        btnOkOnPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SignupPage()),
          );
        },
      ).show();
      return;
    }

    Favorite favorite = Favorite(
      userId: userId,
      itemId: widget.itemId,
      itemType: widget.itemType,
    );

    if (isFavorite) {
      bool removed = await _favoriteService.removeFavorite(favorite);
      if (removed) {
        setState(() => isFavorite = false);
      }
    } else {
      bool added = await _favoriteService.addFavorite(favorite);
      if (added) {
        setState(() => isFavorite = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.03,
      ),
      child: Container(
        height: screenHeight * 0.55,
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          image: DecorationImage(
            image: NetworkImage(widget.imageUrl),
            fit: BoxFit.cover,
          ),
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
          children: [
            // Back and Favorite Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.2),
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.2),
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Info Footer
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Container(
                height: screenHeight * 0.12,
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.black.withOpacity(0.5),
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.price}/hour',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        children: [
                          Text(
                            '📍 ${widget.location}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.045,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
