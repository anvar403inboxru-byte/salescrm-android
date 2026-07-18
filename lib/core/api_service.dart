import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Backend tunnel URL — dəyişdirin əgər tunnel yenilənibsə
  static const String baseUrl = 'https://crowd-walking-stored-disclosure.trycloudflare.com';

  static String? _token;

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await getToken();
    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Auth ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      await saveToken(data['access_token']);
      return {'ok': true, 'user': data['user']};
    }
    return {'ok': false, 'error': 'E-poçt və ya şifrə yanlışdır'};
  }

  // ── Dashboard ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getDashboard() async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/dashboard/'),
      headers: await _headers(),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return {};
  }

  // ── Customers ─────────────────────────────────────────────────────
  static Future<List<dynamic>> getCustomers({String? search}) async {
    final uri = Uri.parse('$baseUrl/api/customers/').replace(
      queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
    );
    final resp = await http.get(uri, headers: await _headers());
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return [];
  }

  static Future<Map<String, dynamic>?> getCustomer(int id) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/customers/$id'),
      headers: await _headers(),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return null;
  }

  static Future<bool> createCustomer(Map<String, dynamic> data) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/customers/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return resp.statusCode == 200 || resp.statusCode == 201;
  }

  static Future<bool> updateCustomer(int id, Map<String, dynamic> data) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/api/customers/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return resp.statusCode == 200;
  }

  static Future<bool> deleteCustomer(int id) async {
    final resp = await http.delete(
      Uri.parse('$baseUrl/api/customers/$id'),
      headers: await _headers(),
    );
    return resp.statusCode == 200;
  }

  // ── Sales ─────────────────────────────────────────────────────────
  static Future<List<dynamic>> getSales({String? search}) async {
    final uri = Uri.parse('$baseUrl/api/sales/').replace(
      queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
    );
    final resp = await http.get(uri, headers: await _headers());
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return [];
  }

  static Future<bool> createSale(Map<String, dynamic> data) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/sales/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return resp.statusCode == 200 || resp.statusCode == 201;
  }

  static Future<bool> updateSale(int id, Map<String, dynamic> data) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/api/sales/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return resp.statusCode == 200;
  }

  static Future<bool> deleteSale(int id) async {
    final resp = await http.delete(
      Uri.parse('$baseUrl/api/sales/$id'),
      headers: await _headers(),
    );
    return resp.statusCode == 200;
  }

  // ── Tasks ─────────────────────────────────────────────────────────
  static Future<List<dynamic>> getTasks({String? status}) async {
    final uri = Uri.parse('$baseUrl/api/tasks/').replace(
      queryParameters: status != null ? {'status': status} : null,
    );
    final resp = await http.get(uri, headers: await _headers());
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return [];
  }

  static Future<bool> createTask(Map<String, dynamic> data) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/tasks/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return resp.statusCode == 200 || resp.statusCode == 201;
  }

  static Future<bool> updateTask(int id, Map<String, dynamic> data) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/api/tasks/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return resp.statusCode == 200;
  }

  static Future<bool> deleteTask(int id) async {
    final resp = await http.delete(
      Uri.parse('$baseUrl/api/tasks/$id'),
      headers: await _headers(),
    );
    return resp.statusCode == 200;
  }

  // ── Quotations ────────────────────────────────────────────────────
  static Future<List<dynamic>> getQuotations({String? search}) async {
    final uri = Uri.parse('$baseUrl/api/quotations/').replace(
      queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
    );
    final resp = await http.get(uri, headers: await _headers());
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return [];
  }

  static Future<Map<String, dynamic>?> getQuotation(int id) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/quotations/$id'),
      headers: await _headers(),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return null;
  }

  static Future<bool> createQuotation(Map<String, dynamic> data) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/quotations/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return resp.statusCode == 200 || resp.statusCode == 201;
  }

  static Future<bool> updateQuotation(int id, Map<String, dynamic> data) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/api/quotations/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return resp.statusCode == 200;
  }

  static Future<bool> deleteQuotation(int id) async {
    final resp = await http.delete(
      Uri.parse('$baseUrl/api/quotations/$id'),
      headers: await _headers(),
    );
    return resp.statusCode == 200;
  }

  static String getExcelUrl(int id) => '$baseUrl/api/quotations/$id/export/excel';

  // ── Team ──────────────────────────────────────────────────────────
  static Future<List<dynamic>> getTeam() async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/users/'),
      headers: await _headers(),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return [];
  }
}
