import 'dart:convert';
import 'package:Athlify/constant/Constants.dart';
import 'package:http/http.dart' as http;
import '../models/rating_model.dart';

class RatingService {
  // إرسال تقييم جديد أو تحديث
  static Future<bool> submitRating({
    required String userId,
    required String itemId,
    required String itemType,
    required double rating,
  }) async {
    final url = Uri.parse('$baseUrl/api/ratings/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'itemId': itemId,
        'itemType': itemType,
        'rating': rating,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // جلب المتوسط
  static Future<RatingResponse> fetchAverageRating(String itemId) async {
    final url = Uri.parse('$baseUrl/api/ratings/average/$itemId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return RatingResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load rating');
    }
  }

  // جلب أعلى 5 عناصر تقييمًا حسب النوع
  static Future<List<dynamic>> getTopRatedItems() async {
    final url = Uri.parse('$baseUrl/api/ratings/topRated');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch top rated items");
    }
  }
}
