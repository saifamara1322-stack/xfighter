import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:xfighter/core/constants/app_constants.dart';

/// Singleton Dio-based HTTP client.
/// All API calls go through this client so auth headers are managed centrally.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${AppConstants.baseUrl}${AppConstants.apiPrefix}',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConstants.accessTokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  // ── Token management ──────────────────────────────────────────────────────

  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
    required String role,
    required String userId,
    required String status,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.accessTokenKey, value: accessToken),
      _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
      _storage.write(key: AppConstants.roleKey, value: role),
      _storage.write(key: AppConstants.userIdKey, value: userId),
      _storage.write(key: AppConstants.userStatusKey, value: status),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
      _storage.delete(key: AppConstants.roleKey),
      _storage.delete(key: AppConstants.userIdKey),
      _storage.delete(key: AppConstants.userStatusKey),
    ]);
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  Future<String?> getStoredRole() =>
      _storage.read(key: AppConstants.roleKey);

  Future<String?> getStoredUserId() =>
      _storage.read(key: AppConstants.userIdKey);

  // ── HTTP helpers ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParams);
    return _handle(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.post(path, data: data);
    return _handle(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.put(path, data: data);
    return _handle(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await _dio.delete(path);
    return _handle(response);
  }

  /// Multipart upload (for documents / images).
  Future<Map<String, dynamic>> uploadFile(
    String path, {
    required File file,
    required String fieldName,
    Map<String, dynamic>? extraFields,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
      ...?extraFields,
    });

    final response = await _dio.post(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return _handle(response);
  }

  /// Multi-file upload (for resubmit endpoints).
  Future<Map<String, dynamic>> uploadFiles(
    String path,
    Map<String, File> files,
  ) async {
    final fields = <String, dynamic>{};
    for (final entry in files.entries) {
      fields[entry.key] = await MultipartFile.fromFile(
        entry.value.path,
        filename: entry.value.path.split('/').last,
      );
    }

    final response = await _dio.post(
      path,
      data: FormData.fromMap(fields),
      options: Options(contentType: 'multipart/form-data'),
    );
    return _handle(response);
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _handle(Response response) {
    final body = response.data;

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      if (body is Map<String, dynamic>) return body;
      // Wrap non-map successful responses
      return {'data': body};
    }

    final message = (body is Map<String, dynamic>)
        ? (body['message'] ?? 'Request failed with status ${response.statusCode}')
        : 'Request failed with status ${response.statusCode}';

    throw Exception(message);
  }
}