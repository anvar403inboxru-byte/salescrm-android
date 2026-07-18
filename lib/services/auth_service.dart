import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  static const _tokenKey = 'crm_token';
  static const _userKey  = 'crm_user';

  final _storage = const FlutterSecureStorage();

  String?            _token;
  Map<String, dynamic>? _user;

  String? get token     => _token;
  bool   get isLoggedIn => _token != null;
  Map<String, dynamic>? get user => _user;
  String get userName   => _user?['full_name'] ?? '';
  String get userRole   => _user?['role'] ?? '';

  Future<void> init() async {
    _token = await _storage.read(key: _tokenKey);
    final u = await _storage.read(key: _userKey);
    if (u != null) _user = jsonDecode(u);
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final data = await ApiService.login(email, password);
      _token = data['access_token'];
      _user  = data['user'];
      await _storage.write(key: _tokenKey, value: _token);
      await _storage.write(key: _userKey,  value: jsonEncode(_user));
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user  = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}