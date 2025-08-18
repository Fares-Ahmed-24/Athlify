import 'dart:convert';

import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List usersJson = decoded['data']['users'];

        return usersJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch users: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }

  // Function to get the user type from SharedPreferences
  Future<String> getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType') ?? 'user';
  }

  Future<String> getSessionId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('sessionId') ?? '';
  }

  Future<String> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? '';
  }

  Future<List<User>> getUsersByRole() async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/role'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        List<dynamic> usersJson = data['data']['users'];
        return usersJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> approveUser(String userId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/users/approve/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to approve user');
    }
  }

  Future<bool> dismissRequest(String userId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/users/dismiss/$userId'),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Error dismissing request: ${response.body}");
      return false;
    }
  }
}
