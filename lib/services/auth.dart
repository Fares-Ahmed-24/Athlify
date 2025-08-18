import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:Athlify/constant/Constants.dart';
// import 'package:Athlify/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': email, 'Password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // User user = User.fromJson(responseData['user']);
        // Store session ID and authentication state
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('sessionId', responseData['sessionId']);
        // await prefs.setString('userType', responseData['User']['userType']);
        await prefs.setString('email', responseData['user']['email']);
        await prefs.setString('userType', responseData['user']['userType']);
        await prefs.setString('userName', responseData['user']['userName']);
        await prefs.setString('userProfile', responseData['user']['imageUrl']);
        await prefs.setString('userId', responseData['user']['id']);

        String? token = await FirebaseMessaging.instance.getToken();
        final userId = responseData['user']['id'];
        final stripeIdResponse = await http.get(
          Uri.parse('$baseUrl/api/users/$userId/stripe-id'),
        );

        if (stripeIdResponse.statusCode == 200) {
          final stripeData = jsonDecode(stripeIdResponse.body);
          final stripeCustomerId = stripeData['stripeCustomerId'];

          print("🔍 Stripe ID response body: ${stripeIdResponse.body}");
          print("🔍 Decoded stripeCustomerId: $stripeCustomerId");

          if (stripeCustomerId != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('stripeCustomerId', stripeCustomerId);
            print('✅ Stripe customer ID loaded and saved again');
          }
        }

        if (token != null) {
          await http.post(
            Uri.parse('$baseUrl/api/users/token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(
                {'userId': responseData['user']['id'], 'token': token}),
          );
        }
        print(
          "Session ID stored in SharedPreferences: ${responseData['sessionId']}",
        );

        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message']
        };
      }
    } catch (error) {
      print("Login Error: $error");
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  Future<bool> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString('sessionId');

      if (sessionId == null) {
        print("No session found in SharedPreferences.");
        return false;
      }

      print("Logging out with Session ID: $sessionId"); // Debugging

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"sessionId": sessionId}), // Send sessionId in request
      );

      if (response.statusCode == 200) {
        await prefs.clear(); // Clear session data
        FirebaseMessaging.instance.deleteToken();

        print("Session cleared from SharedPreferences.");
        return true;
      } else {
        print("Logout failed. Server response: ${response.body}");
        return false;
      }
    } catch (error) {
      print("Logout Error: $error");
      return false;
    }
  }

  Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAuthenticated') ?? false;
  }

  Future<Map<String, dynamic>> changePassword(
      String email, String oldPassword, String newPassword) async {
    // Validate the new password (similar to the backend validation)
    bool isStrongPassword(String password) {
      return password.length >= 8 &&
          RegExp(r'[A-Za-z]').hasMatch(password) &&
          RegExp(r'[0-9]').hasMatch(password) &&
          RegExp(r'[!@#\$&*~_.,%^]').hasMatch(password);
    }

    if (!isStrongPassword(newPassword)) {
      return {
        'success': false,
        'message':
            'Password must be at least 8 characters and include letters, numbers, and symbols.'
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Email': email,
          'oldPassword': oldPassword,
          'newPassword': newPassword
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password changed successfully'};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ??
              'Failed to change password'
        };
      }
    } catch (error) {
      print("Change password error: $error");
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  Future<Map<String, dynamic>> sendOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': email}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'OTP sent successfully'};
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ?? 'Failed to send OTP'
        };
      }
    } catch (error) {
      print("Send OTP error: $error");
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'OTP verified successfully',
          'isVerified': true
        };
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ?? 'Invalid or expired OTP'
        };
      }
    } catch (error) {
      print("Verify OTP error: $error");
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  Future<Map<String, dynamic>> setNewPassword(
      String email, String newPassword) async {
    // Validate the new password (similar to the backend validation)
    bool isStrongPassword(String password) {
      return password.length >= 8 &&
          RegExp(r'[A-Za-z]').hasMatch(password) &&
          RegExp(r'[0-9]').hasMatch(password) &&
          RegExp(r'[!@#\$&*~_.,%^]').hasMatch(password);
    }

    if (!isStrongPassword(newPassword)) {
      return {
        'success': false,
        'message':
            'Password must be at least 8 characters and include letters, numbers, and symbols.'
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/set-new-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': email, 'newPassword': newPassword}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password reset successfully'};
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ?? 'Failed to reset password'
        };
      }
    } catch (error) {
      print("Set new password error: $error");
      return {'success': false, 'message': 'Something went wrong'};
    }
  }
}
