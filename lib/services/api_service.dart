// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.137.184/api/";

  // In-memory
  static String? _token;
  static String? _username; // user_id
  static String? _name; // display name
  static List<String>? _companies;
  static List<String>? _modules;

  // Public getters
  static String? get token => _token;
  static String? get username => _username;
  static String? get name => _name;
  static List<String>? get companies => _companies;
  static List<String>? get modules => _modules;

  // ---------------- AUTH ----------------
  static Future<bool> login(String userId, String password) async {
    try {
      final url = Uri.parse("${baseUrl}accounts/login/");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // JWT token (TokenObtainPairView returns {'refresh', 'access'})
        _token = data['access'];

        // Some of our earlier code returned user under "user" key
        final user = data['user'] ?? {};

        _username = user['user_id']?.toString() ?? user['id']?.toString();
        _name = user['name']?.toString();

        // Company can be single string or list — normalize to List<String>
        if (user['company'] == null) {
          _companies = [];
        } else if (user['company'] is List) {
          _companies = List<String>.from(user['company']);
        } else {
          _companies = [user['company'].toString()];
        }

        // Modules comes as list (hopefully)
        if (user['modules'] == null) {
          _modules = [];
        } else if (user['modules'] is List) {
          _modules = List<String>.from(user['modules']);
        } else {
          // if single value stored as comma separated or single string
          _modules = List<String>.from(user['modules']);
        }

        final prefs = await SharedPreferences.getInstance();
        if (_token != null) await prefs.setString('token', _token!);
        if (_username != null) await prefs.setString('username', _username!);
        if (_name != null) await prefs.setString('name', _name!);
        if (_companies != null)
          await prefs.setStringList('companies', _companies!);
        if (_modules != null) await prefs.setStringList('modules', _modules!);

        return true;
      }
    } catch (e) {
      print("Login error: $e");
    }
    return false;
  }

  static Future<bool> signup(
    String name,
    String userId,
    String password,
    List<String> companies,
    List<String> modules,
  ) async {
    try {
      final url = Uri.parse("${baseUrl}accounts/register/");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'user_id': userId,
          'password': password,
          'company': companies,
          'modules': modules,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Signup error: $e");
      return false;
    }
  }

  // Get saved token (reads from memory first, otherwise from prefs)
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }

  static Future<String?> getUsername() async {
    if (_username != null) return _username;
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username');
    return _username;
  }

  static Future<String?> getName() async {
    if (_name != null) return _name;
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name');
    return _name;
  }

  static Future<List<String>> getCompanies() async {
    if (_companies != null) return _companies!;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('companies') ?? [];
    _companies = list;
    return _companies!;
  }

  static Future<List<String>> getModules() async {
    if (_modules != null) return _modules!;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('modules') ?? [];
    _modules = list;
    return _modules!;
  }

  // ---------------- ISSUES ----------------
  static Future<List<dynamic>> fetchIssues() async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');
    final url = Uri.parse("${baseUrl}issues/");
    final res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) return json.decode(res.body);
    throw Exception('Failed to load issues: ${res.body}');
  }

  static Future<bool> addIssue(Map<String, dynamic> issueData) async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');
    final url = Uri.parse("${baseUrl}issues/");
    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(issueData),
    );
    return res.statusCode == 201;
  }

  // Update (PATCH)
  static Future<bool> updateIssue(
    int issueId,
    Map<String, dynamic> updatedData,
    String token,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/issues/$issueId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updatedData),
    );

    return response.statusCode == 200;
  }
}
