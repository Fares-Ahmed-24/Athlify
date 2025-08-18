import 'dart:convert';
import 'package:Athlify/constant/Constants.dart';
import 'package:http/http.dart' as http;

class OrderService {
  static Future<bool> submitOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to submit order: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error submitting order: $e");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getOrdersByUser(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders/$userId'),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception("Failed to fetch orders");
    }
  }
}
