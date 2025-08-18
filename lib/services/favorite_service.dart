import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/favorit_model.dart';

class FavoriteService {
  final String apiUrl = '${baseUrl}/api/favorite';

  Future<bool> addFavorite(Favorite favorite) async {
    final response = await http.post(
      Uri.parse('$apiUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(favorite
          .toJson()), // Use json.encode to convert the map to a JSON string
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to add favorite: ${response.body}');
      return false;
    }
  }

  // Remove a favorite
  Future<bool> removeFavorite(Favorite favorite) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/remove'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(favorite
          .toJson()), // Use json.encode to convert the map to a JSON string
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to remove favorite: ${response.body}');
      return false;
    }
  }

  Future<List<Favorite>> getFavorites(String userId) async {
    final response = await http.get(Uri.parse('${apiUrl}/$userId'));

    if (response.statusCode == 200) {
      try {
        List<dynamic> data = json.decode(response.body);
        // Use fromJson instead of fromMap
        return data.map((item) => Favorite.fromJson(item)).toList();
      } catch (e) {
        print('Error decoding response: $e');
        return [];
      }
    } else {
      print('Failed to fetch favorites: ${response.body}');
      return [];
    }
  }
}
