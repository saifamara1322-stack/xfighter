import 'api_client.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiClient _apiClient = ApiClient();
  
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _apiClient.get('users');
      if (response is List) {
        return response.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }
  
  Future<User?> getUserById(String id) async {
    try {
      final response = await _apiClient.get('users/$id');
      if (response != null) {
        return User.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }
  
  Future<User> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('users/$id', data);
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }
  
  Future<void> deleteUser(String id) async {
    try {
      await _apiClient.delete('users/$id');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}