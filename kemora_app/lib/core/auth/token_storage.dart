// A simple singleton to hold the JWT token in memory during the session.
// In production, this should be replaced with secure storage.
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage _instance = TokenStorage._();
  static TokenStorage get instance => _instance;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  String? _token;
  String? _refreshToken;

  String? get token => _token;
  String? get refreshToken => _refreshToken;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
  }

  void saveTokens({required String token, String? refreshToken}) {
    _token = token;
    _refreshToken = refreshToken;
    _persistTokens();
  }

  Future<void> clearTokens() async {
    _token = null;
    _refreshToken = null;
    await _clearPersistedTokens();
  }

  Future<void> _persistTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _token ?? '');
    if (_refreshToken != null && _refreshToken!.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, _refreshToken!);
    } else {
      await prefs.remove(_refreshTokenKey);
    }
  }

  Future<void> _clearPersistedTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
}
