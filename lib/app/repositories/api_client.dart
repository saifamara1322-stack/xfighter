import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class ApiClient {
  // For Android emulator use 10.0.2.2, for physical device use your computer's IP
  static const String _baseUrlLocal = 'http://localhost:3000';
  static const String _baseUrlEmulator = 'http://10.0.2.2:3000';
  
  // Auto-detect platform
  static String get baseUrl {
    // If running on Android emulator
    if (Platform.isAndroid) {
      // Check if it's an emulator (you can also check for specific emulator properties)
      return _baseUrlEmulator;
    }
    return _baseUrlLocal;
  }
  
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await secureStorage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/$endpoint');
      print('API GET Request: $url'); // Debug log
      
      final response = await http.get(
        url,
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      print('API GET Error: $e'); // Debug log
      throw Exception('Network error: $e');
    }
  }
  
  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/$endpoint');
      print('API POST Request: $url'); // Debug log
      print('API POST Data: $data'); // Debug log
      
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      print('API POST Error: $e'); // Debug log
      throw Exception('Network error: $e');
    }
  }
  
  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/$endpoint');
      
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/$endpoint');
      
      final response = await http.delete(
        url,
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  dynamic _handleResponse(http.Response response) {
    print('API Response Status: ${response.statusCode}'); // Debug log
    print('API Response Body: ${response.body}'); // Debug log
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else if (response.statusCode == 404) {
      throw Exception('Not found');
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}