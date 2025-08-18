import 'dart:convert';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/trainer_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TrainerService {
  // Get all trainers
  Future<List<Trainer>> getTrainers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/trainerCard/trainers'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> trainersJson = json.decode(response.body);
        return trainersJson.map((json) => Trainer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trainers');
      }
    } catch (e) {
      throw Exception('Failed to load trainers: $e');
    }
  }

  // Add a new trainer
  Future<Map<String, dynamic>> addTrainerCard(
    String name,
    String image,
    String email,
    String price,
    String phone,
    String category,
    String location,
    bool isAvailable,
    String bio,
    int experienceYears,
    List<String> gallery,
    List<String> certifications,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('sessionId');

    try {
      final Map<String, dynamic> body = {
        'name': name,
        'image': image,
        'email': email,
        'price': price,
        'category': category,
        'phone': phone,
        'location': location,
        'isAvailable': isAvailable,
        'bio': bio,
        'experienceYears': experienceYears,
        'gallery': gallery,
        'certifications': certifications,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/trainerCard/trainers'),
        headers: {
          'Content-Type': 'application/json',
          'sessionId': sessionId ?? '',
        },
        body: jsonEncode(body),
      );

      final responseBody = jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'message': responseBody['message'] ?? 'Trainer added successfully!',
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'message': 'Something went wrong. Please try again later.',
      };
    }
  }

  // Update a trainer
  Future<Map<String, dynamic>> updateTrainerCard(
    String id,
    String name,
    String email,
    String location,
    int price,
    String category,
    String phone,
    bool isAvailable,
    String bio,
    int experienceYears,
    List<String> gallery,
    List<String> certifications,
  ) async {
    try {
      final Map<String, dynamic> body = {
        'id': id,
        'name': name,
        'email': email,
        'location': location,
        'price': price,
        'category': category,
        'phone': phone,
        'isAvailable': isAvailable,
        'bio': bio,
        'experienceYears': experienceYears,
        'gallery': gallery,
        'certifications': certifications,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/api/trainerCard/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final responseBody = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': responseBody['message'] ?? 'Trainer updated successfully!',
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'message': 'Something went wrong. Please try again later.',
      };
    }
  }

  // Delete trainer by ID
  Future<Map<String, dynamic>> deleteTrainerById(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/trainerCard/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final responseBody = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': responseBody['message'] ?? 'Trainer deleted successfully!',
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'message': 'Something went wrong. Please try again later.',
      };
    }
  }

  // Get trainer by email
  Future<List<Trainer>> getTrainerByEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/trainerCard/byEmail/$email'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> trainersJson = json.decode(response.body);
        return trainersJson.map((json) => Trainer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trainers by email');
      }
    } catch (e) {
      throw Exception('Failed to load trainers by email: $e');
    }
  }

  // Get trainer by ID
  Future<Trainer?> getTrainerById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/trainerCard/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Trainer.fromJson(json);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

Future<bool> makeTrainerUnavailable(String trainerId) async {
  final url = Uri.parse('$baseUrl/api/trainercard/makeunavailable/$trainerId');

  try {
    final response = await http.put(url);

    if (response.statusCode == 200) {
      print('Trainer is now unavailable');
      return true;
    } else {
      print('Failed to mark unavailable: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error: $e');
    return false;
  }
}

Future<bool> makeTrainerAvailable(String trainerId) async {
  final url = Uri.parse('$baseUrl/api/trainercard/makeavailable/$trainerId');

  try {
    final response = await http.put(url);

    if (response.statusCode == 200) {
      print('Trainer is now available');
      return true;
    } else {
      print('Failed to mark available: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error: $e');
    return false;
  }
}

  // Get trainers by type
  Future<List<Trainer>> getTrainerByType({String type = 'All'}) async {
    final url = Uri.parse('$baseUrl/api/trainerCard/trainerType/$type');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((e) => Trainer.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load trainers by type');
    }
  }
}
