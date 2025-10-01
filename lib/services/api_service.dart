import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.128.175.82:8000/api/";

  // In-memory
  static String? _token;
  static String? _username; // user_id
  static String? _name; // display name
  static List<String>? _companies;
  static List<String>? _modules;
  static bool? _isAdmin;

  // ---------------- GETTERS -----------------
  static String? get token => _token;
  static String? get username => _username;
  static String? get name => _name;
  static List<String>? get companies => _companies;
  static List<String>? get modules => _modules;

  // ---------------- AUTH -----------------
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

        // Save token in prefs
        final prefs = await SharedPreferences.getInstance();
        if (_token != null) await prefs.setString('token', _token!);

        // Fetch user details
        final meUrl = Uri.parse("${baseUrl}accounts/me/");
        final meRes = await http.get(
          meUrl,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $_token",
          },
        );

        if (meRes.statusCode == 200) {
          final user = json.decode(meRes.body);
          _username = user['user_id']?.toString();
          _name = user['name']?.toString();
          _isAdmin =
              (user['is_staff'] == true) || (user['is_superuser'] == true);

          final rawCompanies = user['companies'];
          _companies =
              rawCompanies is List
                  ? List<String>.from(rawCompanies.map((c) => c.toString()))
                  : [];

          final rawModules = user['modules'];
          _modules =
              rawModules is List
                  ? List<String>.from(rawModules.map((m) => m.toString()))
                  : [];

          // Save prefs
          if (_username != null) await prefs.setString('username', _username!);
          if (_name != null) await prefs.setString('name', _name!);
          if (_companies != null) {
            await prefs.setStringList('companies', _companies!);
          }
          if (_modules != null) {
            await prefs.setStringList('modules', _modules!);
          }
          if (_isAdmin != null) {
            await prefs.setBool('is_admin', _isAdmin!);
          }

          return true;
        }
      } else {
        print("Login failed: ${response.body}");
      }
    } catch (e) {
      print("Login error: $e");
    }
    return false;
  }

  // Signup
  static Future<bool> signup(
    String name,
    String userId,
    String email,
    String password,
    List<int> companyIds,
    List<int> moduleIds,
  ) async {
    try {
      final url = Uri.parse("${baseUrl}accounts/register/");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'user_id': userId,
          'email': email,
          'password': password,
          'companies': companyIds,
          'modules': moduleIds,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print("Signup failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Signup error: $e");
      return false;
    }
  }

  // Password Reset
  static Future<bool> requestPasswordReset(String email) async {
    final url = Uri.parse("${baseUrl}accounts/password-reset-request/");
    final response = await http.post(url, body: {"email": email});
    return response.statusCode == 200;
  }

  static Future<bool> verifyResetCode(String email, String code) async {
    final url = Uri.parse("${baseUrl}accounts/password-verify/");
    final response = await http.post(url, body: {"email": email, "code": code});
    return response.statusCode == 200;
  }

  static Future<bool> resetPassword(
    String email,
    String code,
    String password,
  ) async {
    final url = Uri.parse("${baseUrl}accounts/password-reset-confirm/");
    final response = await http.post(
      url,
      body: {"email": email, "code": code, "new_password": password},
    );
    return response.statusCode == 200;
  }

  // ---------------- UTILS -----------------
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

  static Future<bool?> getIsAdminFromPrefs() async {
    if (_isAdmin != null) return _isAdmin;
    final prefs = await SharedPreferences.getInstance();
    _isAdmin = prefs.getBool('is_admin') ?? false;
    return _isAdmin;
  }

  // ---------------- COMPANY / MODULE -----------------
  static Future<List<Map<String, dynamic>>> fetchCompanies() async {
    final url = Uri.parse("${baseUrl}accounts/companies/");
    final res = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(res.body));
    }
    print("fetchCompanies error: ${res.body}");
    return [];
  }

  static Future<List<Map<String, dynamic>>> fetchModules() async {
    final url = Uri.parse("${baseUrl}accounts/modules/");
    final res = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(res.body));
    }
    print("fetchModules error: ${res.body}");
    return [];
  }

  // ---------------- ISSUES -----------------
  static Future<List<dynamic>> fetchIssues() async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');
    final res = await http.get(
      Uri.parse("${baseUrl}issues/"),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) return json.decode(res.body);
    throw Exception('Failed to load issues: ${res.body}');
  }

  static Future<bool> addIssue(Map<String, dynamic> issueData) async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');
    final res = await http.post(
      Uri.parse("${baseUrl}issues/"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(issueData),
    );
    return res.statusCode == 201;
  }

  static Future<bool> updateIssue(
    int issueId,
    Map<String, dynamic> updatedData,
  ) async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');
    final res = await http.put(
      Uri.parse('${baseUrl}issues/$issueId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updatedData),
    );
    return res.statusCode == 200;
  }

  // ---------------- SUMMARY / USER ISSUES (ADMIN ONLY) -----------------
  static Future<List<dynamic>> getSummary({int? year, int? month}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final query =
        "?year=${year ?? DateTime.now().year}&month=${month ?? DateTime.now().month}";
    final response = await http.get(
      Uri.parse("${baseUrl}issues/summary/$query"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load summary");
    }
  }

  static Future<List<dynamic>> fetchIssuesForUser(String userId) async {
    final token = await getToken();
    if (token == null) throw Exception("Token not found");

    final res = await http.get(
      Uri.parse("${baseUrl}issues/user/$userId/"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) return json.decode(res.body);
    throw Exception("Failed to fetch issues for user: ${res.body}");
  }

  // Upcoming Deadline Issues
static Future<List<dynamic>> fetchUpcomingDeadlineIssues(int days) async {
  final token = await ApiService.getToken();
  if (token == null) throw Exception("Token not found");

  final response = await http.get(
    Uri.parse("${ApiService.baseUrl}issues/upcoming_deadline_issues/?days=$days"),
    headers: {"Authorization": "Bearer $token"},
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to load upcoming issues: ${response.body}");
  }
}

  // ---------------- NOTIFICATIONS -----------------
  static Future<List<dynamic>> getUserNotifications() async {
    final res = await _getWithAuth("notifications/");
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to load notifications: ${res.body}');
  }

  static Future<int> getUnreadNotificationCount() async {
    final res = await _getWithAuth("notifications/unread-count/");
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['unread'] as int?) ?? 0;
    }
    throw Exception('Failed to fetch unread count: ${res.body}');
  }

  static Future<bool> markNotificationRead(int id) async {
    final res = await _postWithAuth("notifications/$id/mark-read/", {});
    return res.statusCode == 200;
  }

  // ---------------- PRIVATE HELPERS -----------------
  static Future<http.Response> _getWithAuth(String endpoint) async {
    final token = await getToken();
    if (token == null) throw Exception("Token not found");
    final url = Uri.parse("$baseUrl$endpoint");
    return await http.get(url, headers: {"Authorization": "Bearer $token"});
  }

  static Future<http.Response> _postWithAuth(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await getToken();
    if (token == null) throw Exception("Token not found");
    final url = Uri.parse("$baseUrl$endpoint");
    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(body),
    );
  }
}
