import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/services/payment_service/stripe_service.dart';

class CreateUserService {
  final StripeService stripeService = StripeService();

  Future<Map<String, dynamic>> signUp(String username, String email,
      String password, String age, String phone, String? userType) async {
    try {
      // 1. إرسال بيانات المستخدم للباك
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'Email': email,
          'Password': password,
          'name': username,
          'Age': age,
          'Phone': phone,
          'userType': userType,
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 201) {
        final user = responseBody['user'];
        if (user != null) {
          print("✅ User created successfully: $user");

          try {
            // 2. إنشاء Stripe Customer
            final customerId = await stripeService.createStripeCustomer(
              user['Email'],
              user['name'],
              user['_id'],
            );

            // 3. ربط Stripe Customer ID بالـ User في الباك
            if (customerId != null) {
              final linkResponse = await http.post(
                Uri.parse('$baseUrl/api/users/link-stripe'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'userId': user['_id'],
                  'stripeCustomerId': customerId,
                }),
              );

              if (linkResponse.statusCode == 200) {
                print('✅ Stripe customer linked to user in backend');
              } else {
                print('❌ Failed to link Stripe customer: ${linkResponse.body}');
              }
            } else {
              print("❌ Failed to create Stripe customer");
            }
          } catch (e) {
            print("⚠️ Stripe Error: $e");
          }
        } else {
          print("⚠️ No user data returned from backend");
        }
      }

      return {
        'statusCode': response.statusCode,
        'message': responseBody['message']
      };
    } catch (e) {
      print("❌ Signup Exception: $e");
      return {
        'statusCode': 500,
        'message': 'Something went wrong. Please try again later.'
      };
    }
  }
}
