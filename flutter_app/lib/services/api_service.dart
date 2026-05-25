import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // CHROME
  static const String baseUrl = "http://127.0.0.1:5000";

  static Future<Map<String, dynamic>> login(
    String correo,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({"correo": correo, "password": password}),
    );

    return jsonDecode(response.body);
  }
}
