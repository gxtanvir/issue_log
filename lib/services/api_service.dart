import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL for Flutter Web
  static const String baseUrl = "http://127.0.0.1:8000/api/accounts/";

  // Test backend connection
  static Future<bool> testConnection() async {
    try {
      final url = Uri.parse(baseUrl); // just /api/accounts/
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print("Backend response: ${response.body}");
        return true;
      }
    } catch (e) {
      print("Error connecting to backend: $e");
    }
    return false;
  }

  // Signup
  static Future<bool> signup(String name, String userId, String password) async {
    final url = Uri.parse("${baseUrl}register/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "name": name,
        "user_id": userId,
        "password": password,
      }),
    );
    return response.statusCode == 201;
  }

  // Login
  static Future<bool> login(String userId, String password) async {
    final url = Uri.parse("${baseUrl}login/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "user_id": userId,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["access"]);
      return true;
    }
    return false;
  }

  // Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }
}
