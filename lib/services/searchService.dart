import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/club_model.dart';
import 'package:Athlify/models/trainer_model.dart';

class SearchService {
  Future<Map<String, dynamic>> searchAll(
    String query, {
    String? type,
    double? minPrice,
    double? maxPrice,
    List<String>? categories,
  }) async {
    // بناء باراميترز URL
    final Map<String, String> params = {
      'name': query,
      if (type != null) 'type': type,
      if (minPrice != null) 'minPrice': minPrice.toString(),
      if (maxPrice != null) 'maxPrice': maxPrice.toString(),
      if (categories != null && categories.isNotEmpty)
        'categories': categories.join(','),
    };

    final uri =
        Uri.parse('$baseUrl/api/search').replace(queryParameters: params);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['data'];
    } else {
      throw Exception('Failed to load search results');
    }
  }

  Future<List<Trainer>> fetchTrainers({
    required String query,
    double? minPrice,
    double? maxPrice,
    List<String>? categories,
  }) async {
    final data = await searchAll(
      query,
      type: 'trainers',
      minPrice: minPrice,
      maxPrice: maxPrice,
      categories: categories,
    );

    return (data['trainers'] as List)
        .map((trainerData) => Trainer.fromJson(trainerData))
        .toList();
  }

  Future<List<ClubModel>> fetchClubs({
    required String query,
    double? minPrice,
    double? maxPrice,
    List<String>? categories,
  }) async {
    final data = await searchAll(
      query,
      type: 'clubs',
      minPrice: minPrice,
      maxPrice: maxPrice,
      categories: categories,
    );

    return (data['clubs'] as List)
        .map((clubData) => ClubModel.fromJson(clubData))
        .toList();
  }

  // لو هتضيف ماركت في المستقبل:
  // Future<List<MarketModel>> fetchMarkets(String query) async {
  //   final data = await searchAll(query, type: 'markets');
  //   return (data['markets'] as List)
  //       .map((marketData) => MarketModel.fromJson(marketData))
  //       .toList();
  // }
}
