import 'dart:convert';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/club_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ClubService {
  // دالة للحصول على الأندية
  Future<List<ClubModel>> getClubs() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/api/clubs/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> clubsJson = jsonDecode(response.body);
        return clubsJson
            .map((clubJson) => ClubModel.fromJson(clubJson))
            .toList();
      } else {
        throw Exception('Failed to load clubs');
      }
    } catch (e) {
      throw Exception('Failed to load clubs: $e');
    }
  }

  // دالة إضافة نادي
  Future<Map<String, dynamic>> addClub(
    String name,
    String email,
    String location,
    int price,
    String clubType,
    String imageUrl,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}/api/clubs/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'location': location,
          'price': price,
          'clubType': clubType,
          'image': imageUrl
        }),
      );

      final responseBody = jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'message': responseBody['message'] ?? 'Club added successfully!',
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'message': 'Something went wrong. Please try again later.',
      };
    }
  }

  Future<Map<String, dynamic>> deleteClubById(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}/api/clubs/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final responseBody = jsonDecode(response.body);
      print("🔵 Response Body: $responseBody"); // طباعة الرد للتحقق منه
      return {
        'statusCode': response.statusCode,
        'message': responseBody['message'] ?? 'Club deleted successfully!',
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'message': 'Something went wrong. Please try again later.',
      };
    }
  }

  // 🆕 دالة تعديل نادي

  Future<Map<String, dynamic>> updateClub(
    String id,
    String name,
    String email,
    String location,
    int price,
    String clubType,
    String? image,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('${baseUrl}/api/clubs/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': id,
          'name': name,
          'email': email,
          'location': location,
          'price': price,
          'clubType': clubType,
          'image': image,
        }),
      );

      print('🔵 Status Code: ${response.statusCode}');
      print(
          '📦 Response Body: ${response.body}'); // ✅ هنا بنطبع محتوى الاستجابة

      final responseBody = jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'message': responseBody['message'] ?? 'Club updated successfully!',
      };
    } catch (e) {
      print('🔴 Error during updateClub: $e'); // ✅ هنا بنطبع الخطأ لو حصل
      return {
        'statusCode': 500,
        'message': 'Something went wrong. Please try again later.',
      };
    }
  }

  Future<ClubModel> getClubById(String id) async {
    if (id == 'at_home') {
      return ClubModel(
        id: 'at_home',
        name: 'At Home',
        location: 'Your Location',
        clubType: 'Home',
        price: 0,
        image: '',
        email: '',
        clubStatue: '',
      );
    }

    // Else call your real backend
    final response = await http.get(Uri.parse('$baseUrl/api/clubs/$id'));
    if (response.statusCode == 200) {
      return ClubModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load club');
    }
  }

  Future<List<ClubModel>> getClubsByType({String type = 'All'}) async {
    final url = Uri.parse(
        '$baseUrl/api/clubs/clubType/$type'); // Use the correct route parameter
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((e) => ClubModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load clubs');
    }
  }

  Future<bool> setClubToAvailable(String clubId) async {
    final url = Uri.parse('$baseUrl/api/clubs/$clubId/available');

    try {
      final response = await http.patch(url);
      print(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> setClubToMaintenance(String clubId) async {
    final url = Uri.parse('$baseUrl/api/clubs/$clubId/maintenance');

    try {
      final response = await http.patch(url);
      print(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<List<ClubModel>> getClubsByEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/clubs/byEmail/$email'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> clubsJson = jsonDecode(response.body);
        return clubsJson
            .map((clubJson) => ClubModel.fromJson(clubJson))
            .toList();
      } else {
        throw Exception('Failed to load clubs by email');
      }
    } catch (e) {
      throw Exception('Failed to load clubs by email: $e');
    }
  }
}

class ImageUploadService {
  Future<String?> uploadImageToCloudinary(XFile imageFile) async {
    final url =
        Uri.parse("https://api.cloudinary.com/v1_1/dirhokini/image/upload");

    var request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'trainer_images_preset'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final resData = json.decode(await response.stream.bytesToString());
      return resData['secure_url']; // Return URL
    }

    return null;
  }
}
