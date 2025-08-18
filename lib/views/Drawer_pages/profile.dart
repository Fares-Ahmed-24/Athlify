import 'package:Athlify/models/user_model.dart';
import 'package:Athlify/services/UserController.dart';
import 'package:Athlify/views/booking_view/book_History.dart';
import 'package:Athlify/views/dashboard/DashboardAdmin/dashboardAdmin.dart';
import 'package:Athlify/views/dashboard/DashboardClubOwner&trainer/clubOwnerDashboard.dart';
import 'package:Athlify/views/notification.dart';
import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/intro.dart';
import 'package:Athlify/services/auth.dart';
import 'package:Athlify/views/Drawer_pages/edit_profile.dart';
import 'package:Athlify/widget/CustomeListtile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/club_model.dart';
import '../../services/club.dart';
import '../dashboard/DashboardClubOwner&trainer/trainerDashboard.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService auth = AuthService();
  late Future<Map<String, dynamic>> _userDataFuture;
  late UserController _userController;

  @override
  void initState() {
    super.initState();
    _userController = UserController(); // Initialize UserController
    _userDataFuture = _userController.getUserByEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(top: 14.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 14.0),
          child: Text(
            "Profile",
            style: TextStyle(fontWeight: FontWeight.bold, color: PrimaryColor),
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No user data found."));
          }

          User user = snapshot.data!['user'];
          final imageUrl = user.imageUrl ??
              "https://www.gravatar.com/avatar/placeholder?s=200&d=mp";
          final name = user.Username;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: CircleAvatar(
                          backgroundColor: ContainerColor,
                          radius: 90,
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditProfile()),
                      );
                      setState(() {
                        _userDataFuture = _userController.getUserByEmail();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PrimaryColor,
                      fixedSize: const Size(265, 58),
                    ),
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 35),
                        Customelisttile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NotificationPage()));
                          },
                          leadingIcon: Icons.notifications,
                          title: "Notification",
                        ),
                        const SizedBox(height: 35),
                        Customelisttile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const BookHistory()),
                            );
                          },
                          leadingIcon: Icons.calendar_month,
                          title: "Reservation",
                        ),
                        if (user.userType == 'clubowner' ||
                            user.userType == 'trainer' ||
                            user.userType == 'admin') ...[
                          const SizedBox(height: 35),
                          Customelisttile(
                            onTap: () async {
                              final userType = user.userType;

                              if (userType == 'admin') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => Dashboardadmin()),
                                );
                              } else if (userType == 'clubowner') {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                final String? userEmail =
                                    prefs.getString('email'); // or use your key

                                if (userEmail != null) {
                                  try {
                                    List<ClubModel> clubs = await ClubService()
                                        .getClubsByEmail(userEmail);

                                    if (clubs.isNotEmpty) {
                                      String clubId =
                                          clubs.first.id; // or clubs[0].id

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => Books(clubId: clubId),
                                        ),
                                      );
                                    } else {
                                      // Handle no club found
                                      print("No clubs found for this email.");
                                    }
                                  } catch (e) {
                                    print("Error loading clubs: $e");
                                  }
                                }
                              } else if (userType == 'trainer') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => TrainerSessions(
                                            trainerId: user.id,
                                          )),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "You don't have access to Dashboard."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            leadingIcon: Icons.dashboard_outlined,
                            title: "Dashboard",
                          )
                        ],
                        const SizedBox(height: 35),
                        Customelisttile(
                          onTap: () async {
                            bool success = await auth.logout();
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Logout successful."),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => Or()),
                                (route) => false,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Logout failed. Try again."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          leadingIcon: Icons.logout_sharp,
                          title: "Logout",
                        ),
                        SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
