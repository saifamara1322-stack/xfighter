import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/repositories/user_repository.dart';
import 'package:xfighter/data/repositories/club_repository.dart';
import 'package:xfighter/data/models/user_model.dart';
import 'package:xfighter/data/models/club_model.dart';

/// Resolves emails to entity IDs used by path-parameter APIs.
class UserLookupRepository {
  final ApiClient _api = ApiClient();
  final UserRepository _userRepo = UserRepository();
  final ClubRepository _clubRepo = ClubRepository();

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool isValidEmail(String email) => _emailRegex.hasMatch(email.trim());

  String _normalize(String email) => email.trim().toLowerCase();

  Future<String> resolveUserIdByEmail(
    String email, {
    required UserRole expectedRole,
  }) async {
    final normalized = _normalize(email);
    if (!isValidEmail(normalized)) {
      throw Exception('Enter a valid email address');
    }

    // Some backends support ?email= on /users
    try {
      final body = await _api.get('/users', queryParams: {
        'email': normalized,
        'page': '0',
        'size': '10',
      });
      final id = _pickUserId(body, normalized, expectedRole);
      if (id != null) return id;
    } catch (_) {}

    try {
      final users = await _userRepo.getAllUsers();
      final match = users.where(
        (u) =>
            u.email.toLowerCase() == normalized && u.role == expectedRole,
      );
      if (match.isNotEmpty) return match.first.id;
    } catch (_) {}

    throw Exception(
      'No ${expectedRole.name.toLowerCase()} account found for $normalized',
    );
  }

  String? _pickUserId(
    Map<String, dynamic> body,
    String normalizedEmail,
    UserRole expectedRole,
  ) {
    final data = body['data'];
    List<dynamic> items = [];
    if (data is List) {
      items = data;
    } else if (data is Map && data['content'] is List) {
      items = data['content'] as List;
    }
    for (final item in items) {
      if (item is! Map<String, dynamic>) continue;
      final email = (item['email'] as String?)?.toLowerCase();
      final roleStr = (item['role'] as String?)?.toUpperCase();
      if (email == normalizedEmail &&
          roleStr == expectedRole.name &&
          item['id'] != null) {
        return item['id'].toString();
      }
    }
    return null;
  }

  Future<Club> resolveClubByEmail(String email) async {
    final normalized = _normalize(email);
    if (!isValidEmail(normalized)) {
      throw Exception('Enter a valid club email address');
    }

    try {
      final paged = await _clubRepo.getAllClubs();
      final match = paged.content.where(
        (c) => c.email.toLowerCase() == normalized,
      );
      if (match.isNotEmpty) return match.first;
    } catch (_) {}

    throw Exception('No club found with email $normalized');
  }

  Future<String> resolveFighterIdByEmail(String email) =>
      resolveUserIdByEmail(email, expectedRole: UserRole.FIGHTER);

  Future<String> resolveCoachIdByEmail(String email) =>
      resolveUserIdByEmail(email, expectedRole: UserRole.COACH);

  Future<String> resolveClubIdByEmail(String email) async {
    final club = await resolveClubByEmail(email);
    return club.id;
  }
}
