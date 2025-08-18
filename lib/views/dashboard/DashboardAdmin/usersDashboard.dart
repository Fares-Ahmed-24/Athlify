import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/user_model.dart';
import 'package:Athlify/services/UserController.dart';
import 'package:Athlify/services/getUserType.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UsersDashboardTab extends StatefulWidget {
  const UsersDashboardTab({super.key});

  @override
  State<UsersDashboardTab> createState() => _UsersDashboardTabState();
}

class _UsersDashboardTabState extends State<UsersDashboardTab> {
  List<User> allUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    try {
      final response = await UserService().getAllUsers();
      setState(() => allUsers = response);
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  void _blockUser(String userId) async {
    await UserController().blockUser(userId);
    _fetchUsers();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User blocked for 3 days')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView.builder(
        itemCount: allUsers.length,
        itemBuilder: (context, index) {
          final user = allUsers[index];

          final isBlocked = user.blockUntil != null &&
              DateTime.parse(user.blockUntil!).isAfter(DateTime.now());

          final statusText = isBlocked
              ? "🔴 Blocked until ${DateFormat.yMd().add_jm().format(DateTime.parse(user.blockUntil!))}"
              : "🟢 Active";

          return Card(
            color: ContainerColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(user.imageUrl ?? ""),
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 12),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.Username,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: PrimaryColor)),
                        const SizedBox(height: 4),
                        Text(user.email,
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(statusText,
                            style: TextStyle(
                                color: isBlocked ? Colors.red : Colors.green,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  // Block button
                  ElevatedButton.icon(
                    onPressed: () => _blockUser(user.id),
                    icon: const Icon(Icons.block),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: const Text("Block"),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
