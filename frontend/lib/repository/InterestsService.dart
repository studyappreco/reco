import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class InterestsService {

  static final String baseUrl = dotenv.env['SERVER_BASE_URL']!;

  static Future<List<String>> fetchInterests() async {
    final response = await http.get(Uri.parse('$baseUrl/interests'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<String>();
    }

    throw Exception("Failed to load interests");
  }

}
