import 'dart:async';
import 'dart:convert';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/services/rating%20_service.dart';
import 'package:Athlify/views/bottom_nav_view/recent.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/rating_model.dart';
import '../booking_view/club_details.dart';
import '../booking_view/trainerDetails.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  List<dynamic> clubs = [];
  List<dynamic> trainers = [];
  List<dynamic> topRatedItems = [];

  RatingResponse? _ratingData;

  String selectedClubType = 'All';
  String selectedTrainerType = 'All';

  final List<String> types = [
    'All',
    'Football',
    'Tennis',
    'Basketball',
    'Paddle'
  ];

  @override
  void initState() {
    super.initState();
    fetchClubsByType(selectedClubType);
    fetchTrainersByType(selectedTrainerType);
    fetchTopRatedItems();
  }

  void _loadRatingData(id) async {
    try {
      final data = await RatingService.fetchAverageRating(id.toString());
      if (mounted) {
        setState(() {
          _ratingData = data;
        });
      }
    } catch (e) {
      print('Failed to load rating data: $e');
    }
  }

  void _startAutoSlide() {
    _timer?.cancel(); // لو كان فيه تايمر قديم
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (!mounted || !_pageController.hasClients || topRatedItems.isEmpty)
        return;

      if (_currentPage < topRatedItems.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> fetchTopRatedItems() async {
    try {
      final result = await RatingService.getTopRatedItems();
      if (!mounted) return;

      setState(() {
        topRatedItems = result;
      });

      // شغل الـ auto slide فقط لو فيه عناصر
      if (topRatedItems.isNotEmpty) {
        _startAutoSlide();
      }
    } catch (e) {
      print("Error fetching top rated: $e");
    }
  }

  Future<void> fetchClubsByType(String type) async {
    final url = type == 'All'
        ? Uri.parse("$baseUrl/api/clubs")
        : Uri.parse("$baseUrl/api/clubs/clubType/$type");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Assume each club has a `createdAt` field in ISO 8601 format
        data.sort((a, b) => DateTime.parse(b['createdAt'])
            .compareTo(DateTime.parse(a['createdAt'])));

        setState(() {
          clubs = data.take(3).toList(); // take the 3 most recent
        });
      } else {
        print("Failed to load clubs");
      }
    } catch (e) {
      print("Error fetching clubs: $e");
    }
  }

  Future<void> fetchTrainersByType(String type) async {
    final url = type == 'All'
        ? Uri.parse("$baseUrl/api/trainerCard/trainers")
        : Uri.parse("$baseUrl/api/trainerCard/trainerType/$type");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Sort by most recent (assuming `createdAt` is in ISO format)
        data.sort((a, b) => DateTime.parse(b['createdAt'])
            .compareTo(DateTime.parse(a['createdAt'])));

        setState(() {
          trainers = data.take(3).toList(); // Take the 3 most recent trainers
          selectedTrainerType = type;
        });
      } else {
        print("Failed to load trainers");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching trainers: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget buildClubCard(dynamic club) {
    return GestureDetector(
      onTap: () {
        _loadRatingData(club['_id']);
        print(_ratingData?.averageRating.toString() ?? '0');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClubDetails(
                fieldId: club['_id'],
                rate: _ratingData?.averageRating.toString() ?? '0'),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              image: DecorationImage(
                image: NetworkImage(club['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(club['name'],
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PrimaryColor)),
          Text(club['location'],
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          Text(" ${club['clubType']} - EGP ${club['price']}",
              style: TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }

  Widget buildTrainerCard(dynamic trainer) {
    return GestureDetector(
      onTap: () {
        _loadRatingData(trainer['_id']);
        print(_ratingData?.averageRating.toString() ?? '0');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrainerDetails(
                trainerId: trainer['_id'],
                rate: _ratingData?.averageRating.toString() ?? '0'),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              image: DecorationImage(
                image: NetworkImage(trainer['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(trainer['name'],
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PrimaryColor)),
          Text(trainer['location'],
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          Text(" ${trainer['category']} - EGP ${trainer['price']}",
              style: TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }

  Widget buildTopRatedCard(dynamic item) {
    final isClub = item['itemType'] == 'club';
    RatingResponse? _ratingData;
    void _loadRatingData() async {
      try {
        final data =
            await RatingService.fetchAverageRating(item["id"].toString());
        if (mounted) {
          setState(() {
            _ratingData = data;
          });
        }
      } catch (e) {
        print('Failed to load rating data: $e');
      }
    }

    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: NetworkImage(item['image'] ?? ''),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 👈 النصوص على الشمال
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isClub
                          ? "🏟 Club: ${item['name']}"
                          : "🏋️ Trainer: ${item['name']}",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      item['location'] ?? '',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                // 👉 الريتنج على اليمين
                Text(
                  "⭐ ${(item['averageRating'] ?? 0.0).toStringAsFixed(1)} (${item['ratingCount']})",
                  style: TextStyle(
                      color: Colors.amberAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFilterChips(
      List<String> types, String selectedType, Function(String) onSelected) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: types.map((type) {
          bool isSelected = selectedType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(type),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) => onSelected(type),
              selectedColor: PrimaryColor,
              backgroundColor: Colors.grey[200],
              labelStyle:
                  TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RecentBook(),
              SizedBox(height: 16),
              Text("Trending now",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                height: 180,
                child: topRatedItems.isEmpty
                    ? Center(child: Text("No trending items"))
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: topRatedItems.length,
                        // onPageChanged: (index) {
                        //   setState(() => _currentPage = index);
                        // },
                        itemBuilder: (_, index) =>
                            buildTopRatedCard(topRatedItems[index]),
                      ),
              ),
              SizedBox(height: 16),
              Text("Recently added",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              Text("Clubs",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PrimaryColor)),
              SizedBox(height: 10),
              buildFilterChips(types, selectedClubType, fetchClubsByType),
              SizedBox(height: 15),
              Container(
                height: 270,
                child: clubs.isEmpty
                    ? Center(child: Text("No clubs found"))
                    : PageView.builder(
                        controller: PageController(viewportFraction: 1.0),
                        itemCount: clubs.length,
                        itemBuilder: (_, i) => buildClubCard(clubs[i]),
                      ),
              ),
              Text("Trainers",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PrimaryColor)),
              SizedBox(height: 10),
              buildFilterChips(types, selectedTrainerType, fetchTrainersByType),
              SizedBox(height: 15),
              Container(
                height: 270,
                child: trainers.isEmpty
                    ? Center(child: Text("No trainers found"))
                    : PageView.builder(
                        controller: PageController(viewportFraction: 1.0),
                        itemCount: trainers.length,
                        itemBuilder: (_, i) => buildTrainerCard(trainers[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
