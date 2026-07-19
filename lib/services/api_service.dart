import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Sabit fallback URL — Zero Trust tunnel (dəyişmir)
  static const String _fallbackUrl = 'https://skirts-restructuring-stat-casey.trycloudflare.com';
  static const String _configUrl = 'https://skirts-restructuring-stat-casey.trycloudflare.com/api/config';
  
  static String _baseUrl = _fallbackUrl;
  static final _storage = const FlutterSecureStorage();
  static bool _initialized = false;

  // App başladanda URL-i serverdən al
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      // Əvvəlcə saxlanılmış URL-i yoxla
      final saved = await _storage.read(key: 'backend_url');
      if (saved != null && saved.isNotEmpty) {
        _baseUrl = saved;
      }
      // Serverdən yeni URL al
      final res = await http.get(
        Uri.parse(_configUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final url = data['backend_url'] as String?;
        if (url != null && url.isNotEmpty) {
          _baseUrl = url;
          await _storage.write(key: 'backend_url', value: url);
        }
      }
    } catch (_) {
      // Xəta olsa fallback istifadə et
    }
    _initialized = true;
  }

  static String get baseUrl => _baseUrl;

  static Future<String?> _getToken() => _storage.read(key: 'crm_token');

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final t = await _getToken();
      if (t != null) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  static Future<dynamic> get(String path) async {
    final res = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
    );
    if (res.statusCode == 401) throw Exception('AUTH_ERROR');
    if (res.statusCode >= 400) throw Exception('HTTP ${res.statusCode}');
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final res = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    if (res.statusCode == 401) throw Exception('AUTH_ERROR');
    if (res.statusCode == 429) throw Exception('Çox cəhd. Bir az gözləyin.');
    if (res.statusCode >= 400) {
      final err = jsonDecode(utf8.decode(res.bodyBytes));
      throw Exception(err['detail'] ?? 'Xəta baş verdi');
    }
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (res.statusCode == 401) throw Exception('AUTH_ERROR');
    if (res.statusCode >= 400) {
      final err = jsonDecode(utf8.decode(res.bodyBytes));
      throw Exception(err['detail'] ?? 'Xəta baş verdi');
    }
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final res = await http.patch(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (res.statusCode == 401) throw Exception('AUTH_ERROR');
    if (res.statusCode >= 400) {
      final err = jsonDecode(utf8.decode(res.bodyBytes));
      throw Exception(err['detail'] ?? 'Xəta baş verdi');
    }
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<void> delete(String path) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
    );
    if (res.statusCode == 401) throw Exception('AUTH_ERROR');
    if (res.statusCode >= 400) throw Exception('HTTP ${res.statusCode}');
  }

  // ── Auth ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );
    if (res.statusCode == 429) throw Exception('Çox cəhd. 1 dəqiqə gözləyin.');
    if (res.statusCode >= 400) {
      final err = jsonDecode(utf8.decode(res.bodyBytes));
      throw Exception(err['detail'] ?? 'Xəta baş verdi');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    await _storage.write(key: 'crm_token', value: data['access_token']);
    return data;
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'crm_token');
    await _storage.delete(key: 'backend_url');
    _initialized = false;
    _baseUrl = _fallbackUrl;
  }

  static Future<bool> isLoggedIn() async {
    final t = await _getToken();
    return t != null;
  }

  // ── Customers ─────────────────────────────────────────────────────
  static Future<List<dynamic>> getCustomers() async => await get('/api/customers/');
  static Future<Map<String, dynamic>> getCustomer(int id) async => await get('/api/customers/$id');
  static Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> data) async => await post('/api/customers/', data);
  static Future<Map<String, dynamic>> updateCustomer(int id, Map<String, dynamic> data) async => await put('/api/customers/$id', data);
  static Future<void> deleteCustomer(int id) async => await delete('/api/customers/$id');

  // ── Contacts ──────────────────────────────────────────────────────
  static Future<List<dynamic>> getContacts({int? customerId}) async {
    final q = customerId != null ? '?customer_id=$customerId' : '';
    return await get('/api/contacts/$q');
  }
  static Future<Map<String, dynamic>> createContact(Map<String, dynamic> data) async => await post('/api/contacts/', data);
  static Future<Map<String, dynamic>> updateContact(int id, Map<String, dynamic> data) async => await put('/api/contacts/$id', data);
  static Future<void> deleteContact(int id) async => await delete('/api/contacts/$id');

  // ── Tasks ─────────────────────────────────────────────────────────
  static Future<List<dynamic>> getTasks() async => await get('/api/tasks/');
  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> data) async => await post('/api/tasks/', data);
  static Future<Map<String, dynamic>> updateTask(int id, Map<String, dynamic> data) async => await put('/api/tasks/$id', data);
  static Future<void> deleteTask(int id) async => await delete('/api/tasks/$id');

  // ── Quotations ────────────────────────────────────────────────────
  static Future<List<dynamic>> getQuotations() async => await get('/api/quotations/');
  static Future<Map<String, dynamic>> createQuotation(Map<String, dynamic> data) async => await post('/api/quotations/', data);
  static Future<Map<String, dynamic>> updateQuotation(int id, Map<String, dynamic> data) async => await put('/api/quotations/$id', data);
  static Future<void> deleteQuotation(int id) async => await delete('/api/quotations/$id');

  // ── Interactions ──────────────────────────────────────────────────
  static Future<List<dynamic>> getInteractions(int customerId) async =>
      await get('/api/customers/$customerId/interactions');
  static Future<Map<String, dynamic>> createInteraction(int customerId, Map<String, dynamic> data) async =>
      await post('/api/customers/$customerId/interactions', data);
  static Future<void> deleteInteraction(int customerId, int interactionId) async =>
      await delete('/api/customers/$customerId/interactions/$interactionId');

  // ── Sales ─────────────────────────────────────────────────────────
  static Future<List<dynamic>> getSales() async => await get('/api/sales/');
  static Future<Map<String, dynamic>> createSale(Map<String, dynamic> data) async => await post('/api/sales/', data);
  static Future<Map<String, dynamic>> updateSale(int id, Map<String, dynamic> data) async => await put('/api/sales/$id', data);
  static Future<void> deleteSale(int id) async => await delete('/api/sales/$id');

  // ── Users (assign üçün) ───────────────────────────────────────────
  static Future<List<dynamic>> getUsers() async => await get('/api/auth/users');

  // ── Dashboard ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getDashboardStats() async => await get('/api/dashboard/stats');
}