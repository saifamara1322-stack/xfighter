import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/user_model.dart';
import 'package:xfighter/core/constants/app_constants.dart';

class AuthRepository {
  final ApiClient _api = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<AuthResponse> login(String email, String password) async {
    final body = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final authResp = AuthResponse.fromJson(body['data'] as Map<String, dynamic>);
    await _api.setTokens(
      accessToken: authResp.accessToken,
      refreshToken: authResp.refreshToken,
      role: authResp.role.name,
      userId: authResp.userId,
      status: authResp.status.name,
    );
    await _storage.write(key: AppConstants.userIdKey, value: authResp.userId);
    return authResp;
  }

  // ── Registration ───────────────────────────────────────────────────────────

  Future<AuthResponse> registerFighter(Map<String, dynamic> data) async {
    final body = await _api.post('/auth/register-fighter', data: data);
    final authResp = AuthResponse.fromJson(body['data'] as Map<String, dynamic>);
    await _api.setTokens(
      accessToken: authResp.accessToken,
      refreshToken: authResp.refreshToken,
      role: authResp.role.name,
      userId: authResp.userId,
      status: authResp.status.name,
    );
    return authResp;
  }

  Future<AuthResponse> registerReferee(Map<String, dynamic> data) async {
    final body = await _api.post('/auth/register-referee', data: data);
    final authResp = AuthResponse.fromJson(body['data'] as Map<String, dynamic>);
    await _api.setTokens(
      accessToken: authResp.accessToken,
      refreshToken: authResp.refreshToken,
      role: authResp.role.name,
      userId: authResp.userId,
      status: authResp.status.name,
    );
    return authResp;
  }

  // ── Token refresh ──────────────────────────────────────────────────────────

  Future<AuthResponse> refreshToken() async {
    final stored = await _api.getRefreshToken();
    if (stored == null) throw Exception('No refresh token stored');
    final body = await _api.post('/auth/refresh', data: {'refreshToken': stored});
    final authResp = AuthResponse.fromJson(body['data'] as Map<String, dynamic>);
    await _api.setTokens(
      accessToken: authResp.accessToken,
      refreshToken: authResp.refreshToken,
      role: authResp.role.name,
      userId: authResp.userId,
      status: authResp.status.name,
    );
    return authResp;
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    final stored = await _api.getRefreshToken();
    if (stored != null) {
      try {
        await _api.post('/auth/logout', data: {'refreshToken': stored});
      } catch (_) {
        // Swallow network errors on logout — clear local state regardless
      }
    }
    await _api.clearTokens();
    await _storage.delete(key: AppConstants.userDataKey);
  }

  // ── Current user ──────────────────────────────────────────────────────────

  Future<User> getCurrentUser() async {
    final body = await _api.get('/auth/me');
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<User?> getCachedUser() async {
    final raw = await _storage.read(key: AppConstants.userDataKey);
    if (raw == null) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheUser(User user) async {
    await _storage.write(
      key: AppConstants.userDataKey,
      value: jsonEncode(user.toJson()),
    );
  }

  // ── Session state ─────────────────────────────────────────────────────────

  Future<bool> isLoggedIn() async {
    final token = await _api.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getStoredRole() => _api.getStoredRole();
  Future<String?> getStoredUserId() => _api.getStoredUserId();
}