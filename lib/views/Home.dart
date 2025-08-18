import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/user_model.dart';
import 'package:Athlify/services/UserController.dart';
import 'package:Athlify/views/Drawer_pages/profile.dart';
import 'package:Athlify/views/Drawer_pages/search.dart';
import 'package:Athlify/views/bottom_nav_view/ClubsTab.dart';
import 'package:Athlify/views/bottom_nav_view/HomeTab.dart';
import 'package:Athlify/views/bottom_nav_view/TrainersTab.dart';
import 'package:Athlify/views/bottom_nav_view/drawer.dart';
import 'package:Athlify/views/market%20Screens/market_page.dart';
import 'package:Athlify/widget/animated_navigate.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? sessionId;
  bool isGuest = false;
  String? userName;
  String? userProfile;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sessionId = prefs.getString('sessionId');

    if (sessionId == null) {
      setState(() {
        isGuest = true;
      });
    } else {
      final result = await UserController().getUserByEmail();

      if (result['success']) {
        User user = result['user'];
        setState(() {
          isGuest = false;
          userName = user.Username;
          userProfile = user.imageUrl;
        });
      } else {
        print('Error: ${result['message']}');
        setState(() {
          isGuest = true; // fallback to guest if user fetch fails
        });
      }
    }
  }

  String getGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 18) return "Good Afternoon";
    return "Good Evening";
  }

  final List<Widget> pages = [
    HomeTab(),
    ClubsTab(),
    TrainersTab(),
    market_page(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: PrimaryColor,
      appBar: currentIndex == 3
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              toolbarHeight: currentIndex == 0 ? 150 : kToolbarHeight,
              title: currentIndex == 0
                  ? isGuest
                      ? Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${getGreeting()}, Guest'),
                                      Text('Welcome to Athlify',
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      'https://res.cloudinary.com/dirhokini/image/upload/v1745610464/zlapwxruubilugxmbui6.jpg'),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${getGreeting()}, $userName'),
                                      Text('Welcome Back',
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProfilePage()),
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      userProfile ??
                                          'https://res.cloudinary.com/dirhokini/image/upload/v1745610464/zlapwxruubilugxmbui6.jpg',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                navigateWithSlide(
                                    context, SearchPage(type: 'home'));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(Icons.search, color: Colors.grey),
                                    SizedBox(width: 10),
                                    Text(
                                      "Search...",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentIndex == 1
                              ? "Clubs"
                              : currentIndex == 2
                                  ? "Trainers"
                                  : currentIndex == 3
                                      ? "Market"
                                      : "More",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        if (currentIndex != 3)
                          IconButton(
                            icon: Icon(Icons.search, color: Colors.black),
                            onPressed: () {
                              if (currentIndex == 1) {
                                navigateWithSlide(
                                    context, SearchPage(type: 'club'));
                              } else if (currentIndex == 2) {
                                navigateWithSlide(
                                    context, SearchPage(type: 'trainer'));
                              }
                            },
                          ),
                      ],
                    ),
            ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(70)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          children: pages,
        ),
      ),
      drawer: drawer(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        backgroundColor: PrimaryColor,
        selectedItemColor: ContainerColor,
        unselectedItemColor: SecondaryContainerText,
        onTap: (index) {
          if (index == 4) {
            _scaffoldKey.currentState?.openDrawer();
          } else {
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            setState(() {
              currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer), label: "Clubs"),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: "Trainers"),
          BottomNavigationBarItem(
              icon: Icon(Icons.storefront), label: "Market"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "More"),
        ],
      ),
    );
  }
}
