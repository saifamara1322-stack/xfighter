import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.get('users?email=$email');
      
      if (response is List && response.isNotEmpty) {
        final userData = response[0];
        
        final token = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
        
        await _secureStorage.write(key: 'auth_token', value: token);
        await _secureStorage.write(key: 'user_data', value: json.encode(userData));
        
        return {
          'success': true,
          'token': token,
          'user': User.fromJson(userData),
        };
      }
      
      return {
        'success': false,
        'message': 'Email non trouvé',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }
  
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final existingUsers = await _apiClient.get('users?email=${userData['email']}');
      if (existingUsers is List && existingUsers.isNotEmpty) {
        return {
          'success': false,
          'message': 'Cet email est déjà utilisé',
        };
      }
      
      final newUser = {
        ...userData,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'status': 'pending',
        'verified': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      final response = await _apiClient.post('users', newUser);
      
      return {
        'success': true,
        'user': User.fromJson(response),
        'message': 'Inscription réussie! En attente de vérification.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur d\'inscription: $e',
      };
    }
  }
  
  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'user_data');
  }
  
  Future<User?> getCurrentUser() async {
    final userData = await _secureStorage.read(key: 'user_data');
    if (userData != null) {
      try {
        return User.fromJson(json.decode(userData));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'auth_token');
    return token != null;
  }
}