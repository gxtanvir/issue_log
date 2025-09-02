import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.101.243.82:8000/api/";

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

  // Authentications
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

        _token = data['access'];
        final user = data['user'] ?? {};

        _username = user['user_id']?.toString() ?? user['id']?.toString();
        _name = user['name']?.toString();

        // ✅ normalize companies to List<String>
        final rawCompanies = user['companies'];
        if (rawCompanies is List) {
          _companies = List<String>.from(rawCompanies.map((c) => c.toString()));
        } else if (rawCompanies is String && rawCompanies.isNotEmpty) {
          _companies = [rawCompanies];
        } else {
          _companies = [];
        }

        // ✅ normalize modules to List<String>
        final rawModules = user['modules'];
        if (rawModules is List) {
          _modules = List<String>.from(rawModules.map((m) => m.toString()));
        } else if (rawModules is String && rawModules.isNotEmpty) {
          _modules = [rawModules];
        } else {
          _modules = [];
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
          'companies': companies,
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

  static Future<List<String>> fetchCompanies() async {
    final token = await getToken();
    if (token == null) return [];
    final url = Uri.parse("${baseUrl}accounts/companies/");
    final res = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<String>.from(data.map((e) => e.toString()));
    }
    return [];
  }

  static Future<List<String>> fetchModules() async {
    final token = await getToken();
    if (token == null) return [];
    final url = Uri.parse("${baseUrl}accounts/modules/");
    final res = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<String>.from(data.map((e) => e.toString()));
    }
    return [];
  }

  // Issues
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
