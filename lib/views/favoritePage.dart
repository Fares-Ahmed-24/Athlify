import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/functions/update_delete_club.dart';
import 'package:Athlify/functions/update_delete_trainerCard.dart';
import 'package:Athlify/models/club_model.dart';
import 'package:Athlify/models/favorit_model.dart';
import 'package:Athlify/models/trainer_model.dart';
import 'package:Athlify/services/club.dart';
import 'package:Athlify/services/favorite_service.dart';
import 'package:Athlify/services/getUserType.dart';
import 'package:Athlify/services/trainer.dart';
import 'package:Athlify/widget/clubcard.dart';
import 'package:Athlify/widget/trainercard.dart';
import 'package:flutter/material.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FavoriteService _favoriteService = FavoriteService();
  final ClubService _clubService = ClubService();
  final TrainerService _trainerService = TrainerService();

  List<Map<String, dynamic>> _favorites = []; // holds both clubs & trainers

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    String userId = await getUserId();
    List<Favorite> favorites = await _favoriteService.getFavorites(userId);

    List<Map<String, dynamic>> combinedList = [];

    for (var fav in favorites) {
      if (fav.itemType == 'club') {
        ClubModel? club = await _clubService.getClubById(fav.itemId.toString());
        if (club != null) {
          combinedList.add({'type': 'club', 'data': club});
        }
      } else if (fav.itemType == 'trainer') {
        Trainer? trainer =
            await _trainerService.getTrainerById(fav.itemId.toString());
        if (trainer != null) {
          combinedList.add({'type': 'trainer', 'data': trainer});
        }
      }
    }

    setState(() {
      _favorites = combinedList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColor,
        title: const Text(
          'My Favorites',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
      ),
      body: _favorites.isEmpty
          ? const Center(child: Text("No favorite items yet."))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final item = _favorites[index];
                  if (item['type'] == 'club') {
                    final ClubModel club = item['data'];
                    return ClubCardWidget(
                      club: club,
                      onTapDelete: () {
                        showDeleteConfirmationDialog(
                            context: context, club: club);
                      },
                      onTapUpdate: () {
                        showEditClubDialog(context: context, club: club);
                      },
                    );
                  } else if (item['type'] == 'trainer') {
                    final Trainer trainer = item['data'];
                    return TrainerCardWidget(
                      trainer: trainer,
                      onTapDelete: () {
                        showDeleteConfirmationDialogTrainer(
                            context: context, trainer: trainer);
                      },
                      onTapUpdate: () {
                        showEditTrainerDialog(
                            context: context, trainer: trainer);
                      },
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
    );
  }

  Future<String> getUserId() async {
    final UserService _userData = UserService();
    return _userData.getEmail();
  }
}
