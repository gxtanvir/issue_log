import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api/";

  // Store token & username in memory
  static String? _token;
  static String? _username;

  // Getters
  static String? get token => _token;
  static String? get username => _username;

  // ================== AUTH ==================
  // Login
  static Future<bool> login(String userId, String password) async {
    try {
      final url = Uri.parse("${baseUrl}accounts/login/");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"user_id": userId, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data["access"];
        _username = data["username"] ?? "unknown"; // fallback if backend fails

        final prefs = await SharedPreferences.getInstance();
        if (_token != null) await prefs.setString("token", _token!);
        if (_username != null) await prefs.setString("username", _username!);

        return true;
      }
    } catch (e) {
      print("Login error: $e");
    }
    return false;
  }

// Signup
static Future<bool> signup(String name, String userId, String password, List<String> companies, List<String> modules) async {
  try {
    final url = Uri.parse("${baseUrl}accounts/register/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "name": name,
        "user_id": userId,
        "password": password,
        "company": companies,
        "modules": modules,
      }),
    );
    return response.statusCode == 201;
  } catch (e) {
    print("Signup error: $e");
    return false;
  }
}


  // Get saved token
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token");
    return _token;
  }

  // Get saved username
  static Future<String?> getUsername() async {
    if (_username != null) return _username;
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString("username");
    return _username;
  }

  // ================== ISSUES ==================
  // Fetch all issues
  static Future<List<dynamic>> fetchIssues() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("Token not found");

      final url = Uri.parse("${baseUrl}issues/");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load issues: ${response.body}");
      }
    } catch (e) {
      throw Exception("Fetch issues error: $e");
    }
  }

  // Add new issue
  static Future<bool> addIssue(Map<String, dynamic> issueData) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("Token not found");

      final url = Uri.parse("${baseUrl}issues/");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(issueData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Add issue error: $e");
      return false;
    }
  }
}
