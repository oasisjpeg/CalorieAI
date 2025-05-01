import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/utils/env.dart';

class ImgBBService {
  final log = Logger('ImgBBService');
  
  static const _baseUrl = 'https://api.imgbb.com/1/upload';
  
  final _client = http.Client();

  Future<String> uploadImage(Uint8List imageBytes) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl').replace(queryParameters: {
          'key': Env.imgbbApiKey,
        }),
        body: {
          'image': base64Encode(imageBytes),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to upload image: ${response.body}');
      }

      final data = jsonDecode(response.body);
      if (!data['success']) {
        throw Exception('Image upload failed: ${data['error']['message']}');
      }

      return data['data']['url'] as String;
    } catch (e) {
      log.severe('Error uploading image to ImgBB: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
