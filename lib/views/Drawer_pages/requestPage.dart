import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/user_model.dart';
import 'package:Athlify/services/getUserType.dart';

class Requestpage extends StatefulWidget {
  const Requestpage({super.key});

  @override
  State<Requestpage> createState() => _RequestpageState();
}

class _RequestpageState extends State<Requestpage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: FutureBuilder<List<User>>(
        future: UserService().getUsersByRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<User> users = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.05,
                  left: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                  bottom: screenHeight * 0.02,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            // search action
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      "Requests",
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        color: PrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.filter_list),
                            SizedBox(width: screenWidth * 0.02),
                            Text("Filters",
                                style:
                                    TextStyle(fontSize: screenWidth * 0.035)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.swap_vert),
                            SizedBox(width: screenWidth * 0.02),
                            Text("Newest to oldest",
                                style:
                                    TextStyle(fontSize: screenWidth * 0.035)),
                          ],
                        ),
                        const Icon(Icons.view_list_sharp),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.022,
                    vertical: screenHeight * 0.01,
                  ),
                  child: users.isEmpty
                      ? const Center(
                          child: Text("No requests found",
                              style: TextStyle(fontSize: 18)))
                      : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Container(
                              padding: EdgeInsets.all(screenWidth * 0.035),
                              margin:
                                  EdgeInsets.only(bottom: screenHeight * 0.02),
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          user.Username,
                                          style: TextStyle(
                                            color: PrimaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.05,
                                          ),
                                        ),
                                      ),
                                      Wrap(
                                        spacing: screenWidth * 0.02,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              try {
                                                await UserService()
                                                    .approveUser(user.id);
                                                setState(() {
                                                  user.userType =
                                                      user.requestedRole!;
                                                  user.requestedRole = null;
                                                });
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    backgroundColor:
                                                        Colors.green,
                                                    content: Text(
                                                        '${user.Username} approved successfully'),
                                                  ),
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Failed to approve user: $e')),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: PrimaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                            ),
                                            child: const Text(
                                              "Approve",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              bool success = await UserService()
                                                  .dismissRequest(user.id);
                                              if (success) {
                                                setState(() {
                                                  user.requestedRole = null;
                                                });
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    backgroundColor:
                                                        SecondaryColor,
                                                    content: Text(
                                                        '${user.Username} approve rejected'),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          "Failed to dismiss request")),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: SecondaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                            ),
                                            child: const Text(
                                              "Dismiss",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(thickness: 3),
                                  SizedBox(height: screenHeight * 0.01),
                                  Text("Email: ${user.email}",
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.04)),
                                  SizedBox(height: screenHeight * 0.01),
                                  Text("Phone: ${user.phone}",
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.04)),
                                  SizedBox(height: screenHeight * 0.01),
                                  Text(
                                    "Request Type: ${user.requestedRole ?? "None"}",
                                    style:
                                        TextStyle(fontSize: screenWidth * 0.04),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
