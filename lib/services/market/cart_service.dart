import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Athlify/constant/Constants.dart';

class CartService {
  // Get all products in cart
  Future<List<Map<String, dynamic>>> fetchCartProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email == null) throw Exception('User email not found');

    final response = await http.get(
      Uri.parse('$baseUrl/api/users/cart/$email'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['cart']);
    } else {
      throw Exception('Failed to load cart');
    }
  }

  // Remove specific product from cart
  Future<void> removeProductFromCart(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email == null) throw Exception('User email not found');

    final response = await http.delete(
      Uri.parse('$baseUrl/api/users/cart/$email/$productId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove product');
    }
  }

  // Clear the entire cart
  Future<void> clearCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email == null) throw Exception('User email not found');

    final response = await http.delete(
      Uri.parse('$baseUrl/api/users/cart/$email'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart');
    }
  }
}
