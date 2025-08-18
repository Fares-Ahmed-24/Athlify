import 'dart:convert';
import 'package:Athlify/constant/Constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductService {
  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/api/products'));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((product) => product as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Map<String, dynamic>> updateProduct({
    required String productId,
    required String productName,
    required int productPrice,
    required String productImage,
    required String productDescription,
    required List<Map<String, dynamic>> sizes,
    required String productType, // ✅ أضف النوع هنا كمان
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/products/update/$productId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'productName': productName,
          'productPrice': productPrice,
          'productImage': productImage,
          'productDescription': productDescription,
          'sizes': sizes,
          'productType': productType, // ✅ وأضفها هنا
        }),
      );

      final responseBody = json.decode(response.body);

      return {
        'statusCode': response.statusCode,
        'message': responseBody['message'] ?? 'Product updated',
        'data': responseBody,
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'message': 'Something went wrong. Please try again later.',
      };
    }
  }

  Future<Map<String, dynamic>> addProduct(
    String productName,
    int productPrice,
    String productImage,
    String productDescription,
    List<Map<String, dynamic>> sizes,
    String productType,
    String userId, // ✅ أضف userId كـ parameter
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/products/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'productName': productName,
          'productPrice': productPrice,
          'productImage': productImage,
          'productDescription': productDescription,
          'sizes': sizes,
          'productType': productType,
          'userId': userId, // ✅ أرسله في جسم الـ request
        }),
      );

      final responseBody = json.decode(response.body);

      return {
        'statusCode': response.statusCode,
        'message': responseBody['message'] ?? 'Product added',
        'data': responseBody,
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'message': 'Something went wrong. Please try again later.',
      };
    }
  }

  Future<void> deleteProductById(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/products/delete/$productId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> addToCart(
    BuildContext parentContext,
    Map<String, dynamic> product,
    int quantity,
    String? selectedSize, // أضفت هنا متغير الحجم (اختياري لو المنتج بدون حجم)
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    final response = await http.post(
      Uri.parse('$baseUrl/api/users/cart'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'productId': product['_id'],
        'quantity': quantity,
        'size': selectedSize, // إرسال الحجم مع الطلب
      }),
    );

    final responseBody = json.decode(response.body);
    ScaffoldMessenger.of(parentContext).showSnackBar(
      SnackBar(
        content: Text(responseBody['message']),
        backgroundColor: response.statusCode == 200 ? Colors.green : Colors.red,
      ),
    );
  }

  ////this service is use for add to favorite for product to favorite it
  Future<void> addToFavourites(
    BuildContext parentContext,
    Map<String, dynamic> product,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    final response = await http.post(
      Uri.parse('$baseUrl/api/users/favourites/addFavourite'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'productId': product['_id'],
      }),
    );

    ScaffoldMessenger.of(parentContext).showSnackBar(
      SnackBar(
        content: Text(
          response.statusCode == 200
              ? json.decode(response.body)['message']
              : 'The product already in favourites',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: response.statusCode == 200 ? Colors.green : Colors.red,
        elevation: 6,
      ),
    );
  }

  ////this service we use it as search in the market page
  List<Map<String, dynamic>> getFilteredProducts(
    List<Map<String, dynamic>> products,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return products;

    return products.where((product) {
      final name = product['productName']?.toString().toLowerCase() ?? '';
      return name.contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<Map<String, dynamic>> restockProduct(
      String productId, List<Map<String, dynamic>> sizes) async {
    try {
      final url = Uri.parse('$baseUrl/api/products/restock/$productId');
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sizes': sizes}),
      );

      if (response.statusCode == 200) {
        return {
          'statusCode': 200,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'statusCode': response.statusCode,
          'message': jsonDecode(response.body)['message'] ??
              'Failed to restock product',
        };
      }
    } catch (e) {
      return {
        'statusCode': 500,
        'message': e.toString(),
      };
    }
  }
}
