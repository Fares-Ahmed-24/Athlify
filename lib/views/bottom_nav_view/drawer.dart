import 'package:Athlify/services/UserController.dart';
import 'package:Athlify/views/booking_view/book_History.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Athlify/intro.dart';
import 'package:Athlify/services/auth.dart';
import 'package:Athlify/views/Home.dart';
import 'package:Athlify/views/Drawer_pages/add.dart';
import 'package:Athlify/views/Drawer_pages/addTrainer.dart';
import 'package:Athlify/views/favoritePage.dart';
import 'package:Athlify/views/Drawer_pages/profile.dart';
import 'package:Athlify/views/Drawer_pages/requestPage.dart';
import 'package:Athlify/views/Drawer_pages/search.dart';
import 'package:Athlify/widget/drawer%20widget/about.dart';

class drawer extends StatefulWidget {
  @override
  State<drawer> createState() => _drawerState();
}

class _drawerState extends State<drawer> {
  final auth = AuthService();
  bool isGuest = false;
  String userName = 'Guest';
  String email = 'guest@gmail.com';
  String userType = 'guest';
  String profileImage =
      'https://res.cloudinary.com/dirhokini/image/upload/v1745610464/zlapwxruubilugxmbui6.jpg';

  @override
  void initState() {
    super.initState();
    _loadUserDataFromPrefs();
  }

  Future<void> _loadUserDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('sessionId');

    if (sessionId == null) {
      setState(() {
        isGuest = true;
      });
    } else {
      isGuest = false;

      final result = await UserController().getUserByEmail();

      if (result['success']) {
        final user = result['user'];
        setState(() {
          userName = user.Username ?? 'User';
          email = user.email ?? '';
          userType = user.userType ?? '';
          profileImage = user.imageUrl ??
              'https://res.cloudinary.com/dirhokini/image/upload/v1745610464/zlapwxruubilugxmbui6.jpg';
        });
      } else {
        // Fallback in case fetching user fails
        setState(() {
          userName = 'User';
          email = '';
          userType = '';
          profileImage =
              'https://res.cloudinary.com/dirhokini/image/upload/v1745610464/zlapwxruubilugxmbui6.jpg';
          isGuest = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(40)),
      ),
      child: Container(
        color: Color.fromRGBO(36, 53, 85, 1),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                userName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(email),
              currentAccountPicture: isGuest
                  ? CircleAvatar(backgroundImage: NetworkImage(profileImage))
                  : GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()),
                        );
                      },
                      child: CircleAvatar(
                          backgroundImage: NetworkImage(profileImage)),
                    ),
              decoration: BoxDecoration(
                color: Color.fromRGBO(36, 53, 85, 1),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text("Home", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
            if (!isGuest) ...[
              ListTile(
                leading: Icon(Icons.search, color: Colors.white),
                title: Text("Search", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchPage(type: 'home')),
                  );
                },
              ),
              if (userType == 'admin')
                ListTile(
                  leading: Icon(Icons.list, color: Colors.white),
                  title:
                      Text("Requests", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Requestpage()),
                    );
                  },
                ),
              if (userType == 'trainer' || userType == 'admin')
                ListTile(
                  leading: Icon(Icons.add, color: Colors.white),
                  title: Text("Add Trainer",
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Addtrainer()),
                    );
                  },
                ),
              if (userType == 'clubowner' || userType == 'admin')
                ListTile(
                  leading: Icon(Icons.add, color: Colors.white),
                  title:
                      Text("Add Club", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddClubPage()),
                    );
                  },
                ),
              ListTile(
                leading: Icon(Icons.shopping_cart, color: Colors.white),
                title:
                    Text("Reservation", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BookHistory()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite, color: Colors.white),
                title: Text("Favorite", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FavoritePage()),
                  );
                },
              ),
              Divider(color: Colors.white54, thickness: 1),
              ListTile(
                leading: Icon(Icons.person, color: Colors.white),
                title: Text("Profile", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),
            ],
            ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text("About", style: TextStyle(color: Colors.white)),
              onTap: () => showAboutAthlifyDialog(context),
            ),
            if (!isGuest)
              ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text("Logout", style: TextStyle(color: Colors.white)),
                onTap: () async {
                  bool success = await auth.logout();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Logout successful."),
                          backgroundColor: Colors.green),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Or()),
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Logout failed."),
                          backgroundColor: Colors.red),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
