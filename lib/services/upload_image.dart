import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UploadImageService {
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

    return null; // Upload failed
  }
}
