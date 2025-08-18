import 'dart:convert';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserController {
  Future<Map<String, dynamic>> updateUserDetails(
      String email, String name, int age, String phone, String imageUrl) async {
    final url = Uri.parse(
        '$baseUrl/api/users/edit/$email'); // Use the email in the route

    final Map<String, dynamic> requestBody = {
      'email': email,
      'name': name,
      'Age': age,
      'Phone': phone,
      'imageUrl': imageUrl,
    };

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['user']
        };
      } else {
        final responseData = json.decode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'An error occurred'
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message':
            'Failed to connect to the server. Please check your internet connection.'
      };
    }
  }


  Future<Map<String, dynamic>> getUserByEmail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');

      if (email == null) {
        return {
          'success': false,
          'message': 'No email found in SharedPreferences.'
        };
      }

      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/users/email/$email'), // Assuming your endpoint allows email-based fetching
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Convert the response data to the User model
        User user = User.fromJson(responseData['user']);

        return {
          'success': true,
          'message': 'User data fetched successfully',
          'user': user, // Return the user object
        };
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'],
        };
      }
    } catch (error) {
      print("Get User Error: $error");
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  Future<void> blockUser(String userId) async {
    final url = Uri.parse('$baseUrl/api/users/blockUser/$userId');

    final response = await http.post(url);

    if (response.statusCode == 200) {
      print('User blocked successfully');
    } else {
      print('Failed to block user: ${response.body}');
    }
  }


  Future<void> reportUser(String userId) async {
    final url = Uri.parse('$baseUrl/api/users/report/$userId');

    final response = await http.patch(url);

    if (response.statusCode == 200) {
      print('User reported successfully');
    } else {
      print('Failed to report user: ${response.body}');
    }
  }
}