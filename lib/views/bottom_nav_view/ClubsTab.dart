import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/club_model.dart';
import 'package:Athlify/services/club.dart';
import 'package:Athlify/widget/Filterchip.dart';
import 'package:Athlify/widget/clubcard.dart';

class ClubsTab extends StatefulWidget {
  @override
  State<ClubsTab> createState() => _ClubsTabState();
}

class _ClubsTabState extends State<ClubsTab> {
  final ClubService _clubService = ClubService();
  String selectedType = 'All'; // Store selected filter type
  late Future<List<ClubModel>> futureClubs;

  @override
  void initState() {
    super.initState();
    // Initially load all clubs
    futureClubs = _clubService.getClubsByType(type: selectedType);
  }

  // This function updates the filter and reloads the club list
  void _filterClubs(String type) {
    setState(() {
      selectedType = type;
      futureClubs = _clubService.getClubsByType(type: type);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              // Filter chips row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Clubsfilterchip(
                      isSelected: selectedType == 'All',
                      label: "All",
                      onSelected: () => _filterClubs('All'),
                    ),
                    Clubsfilterchip(
                      isSelected: selectedType == 'Football',
                      label: "Football",
                      onSelected: () => _filterClubs('Football'),
                    ),
                    Clubsfilterchip(
                      isSelected: selectedType == 'Tennis',
                      label: "Tennis",
                      onSelected: () => _filterClubs('Tennis'),
                    ),
                    Clubsfilterchip(
                      isSelected: selectedType == 'Basketball',
                      label: "Basketball",
                      onSelected: () => _filterClubs('Basketball'),
                    ),
                    Clubsfilterchip(
                      isSelected: selectedType == 'Paddle',
                      label: "Paddle",
                      onSelected: () => _filterClubs('Paddle'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text("Recently added",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SecondaryColor)),
              SizedBox(height: 8),

              // FutureBuilder listens to the updated future
              Expanded(
                child: FutureBuilder<List<ClubModel>>(
                  future: futureClubs,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No clubs found."));
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var club = snapshot.data![index];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: ClubCardWidget(
                                club: club,
                              )),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
