import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/user_model.dart';

class UserRepository {
  final ApiClient _api = ApiClient();

  Future<List<User>> getAllUsers() async {
    final body = await _api.get('/users');
    final data = body['data'];
    if (data is List) {
      return data
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    // Handle paged response
    if (data is Map<String, dynamic> && data.containsKey('content')) {
      return (data['content'] as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<User> getUserById(String id) async {
    final body = await _api.get('/users/$id');
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  // Legacy stubs kept so UserController still compiles
  Future<List<User>> getUsers() => getAllUsers();

  Future<User> addUser(User user) => Future.error(
      'Direct user creation not supported. Use auth/register-* endpoints.');

  Future<User> updateUser(User user) => Future.error(
      'Direct user update not supported. Use role-specific update endpoints.');

  Future<void> deleteUser(String userId) =>
      Future.error('Direct user delete not supported by this API.');
}