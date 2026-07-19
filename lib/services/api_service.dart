import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://sticks-tier-remembered-rfc.trycloudflare.com';
  static final _storage = const FlutterSecureStorage();

  static Future<String?> _getToken() => _storage.read(key: 'crm_token');

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final t = await _getToken();
      if (t != null) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  // ── Auth ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'username=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}',
    );
    if (res.statusCode != 200) throw Exception('Login xətası: ${res.statusCode}');
    return jsonDecode(res.body);
  }

  // ── Generic ───────────────────────────────────────────────────────
  static Future<dynamic> get(String path, {Map<String, String>? params}) async {
    var uri = Uri.parse('$baseUrl$path');
    if (params != null) uri = uri.replace(queryParameters: params);
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode == 401) throw Exception('Unauthorized');
    if (res.statusCode >= 400) throw Exception('GET $path → ${res.statusCode}');
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (res.statusCode >= 400) throw Exception('POST $path → ${res.statusCode}: ${res.body}');
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (res.statusCode >= 400) throw Exception('PUT $path → ${res.statusCode}: ${res.body}');
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<void> delete(String path) async {
    final res = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );
    if (res.statusCode >= 400) throw Exception('DELETE $path → ${res.statusCode}');
  }

  // ── Customers ─────────────────────────────────────────────────────
  static Future<List<dynamic>> getCustomers({String? search, String? status}) async {
    final p = <String, String>{};
    if (search != null && search.isNotEmpty) p['search'] = search;
    if (status != null && status.isNotEmpty) p['status'] = status;
    return await get('/api/customers/', params: p);
  }

  static Future<Map<String, dynamic>> getCustomer(int id) async =>
      await get('/api/customers/$id');

  static Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> data) async =>
      await post('/api/customers/', data);

  static Future<Map<String, dynamic>> updateCustomer(int id, Map<String, dynamic> data) async =>
      await put('/api/customers/$id', data);

  static Future<void> deleteCustomer(int id) async =>
      await delete('/api/customers/$id');

  // ── Contacts ──────────────────────────────────────────────────────
  static Future<List<dynamic>> getContacts({String? search, int? customerId}) async {
    final p = <String, String>{};
    if (search != null && search.isNotEmpty) p['search'] = search;
    if (customerId != null) p['customer_id'] = customerId.toString();
    return await get('/api/contacts/', params: p);
  }

  static Future<Map<String, dynamic>> getContact(int id) async =>
      await get('/api/contacts/$id');

  static Future<Map<String, dynamic>> createContact(Map<String, dynamic> data) async =>
      await post('/api/contacts/', data);

  static Future<Map<String, dynamic>> updateContact(int id, Map<String, dynamic> data) async =>
      await put('/api/contacts/$id', data);

  static Future<void> deleteContact(int id) async =>
      await delete('/api/contacts/$id');

  // ── Quotations ────────────────────────────────────────────────────
  static Future<List<dynamic>> getQuotations({String? status}) async {
    final p = <String, String>{};
    if (status != null && status.isNotEmpty) p['status'] = status;
    return await get('/api/quotations/', params: p);
  }

  static Future<Map<String, dynamic>> getQuotation(int id) async =>
      await get('/api/quotations/$id');

  static Future<Map<String, dynamic>> createQuotation(Map<String, dynamic> data) async =>
      await post('/api/quotations/', data);

  static Future<Map<String, dynamic>> updateQuotation(int id, Map<String, dynamic> data) async =>
      await put('/api/quotations/$id', data);

  static Future<void> deleteQuotation(int id) async =>
      await delete('/api/quotations/$id');

  // ── Tasks ─────────────────────────────────────────────────────────
  static Future<List<dynamic>> getTasks({String? status, String? priority}) async {
    final p = <String, String>{};
    if (status != null && status.isNotEmpty) p['status'] = status;
    if (priority != null && priority.isNotEmpty) p['priority'] = priority;
    return await get('/api/tasks/', params: p);
  }

  static Future<Map<String, dynamic>> getTask(int id) async =>
      await get('/api/tasks/$id');

  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> data) async =>
      await post('/api/tasks/', data);

  static Future<Map<String, dynamic>> updateTask(int id, Map<String, dynamic> data) async =>
      await put('/api/tasks/$id', data);

  static Future<void> deleteTask(int id) async =>
      await delete('/api/tasks/$id');

  // ── Users (assign üçün) ───────────────────────────────────────────
  static Future<List<dynamic>> getUsers() async =>
      await get('/api/users/');

  // ── Dashboard ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getDashboard() async =>
      await get('/api/dashboard/stats');
}