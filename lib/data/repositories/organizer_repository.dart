import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/user_model.dart';
import 'package:xfighter/data/models/admin_model.dart';
import 'package:xfighter/data/models/organizer_model.dart';

class OrganizerRepository {
  final ApiClient _api = ApiClient();

  // ── List ──────────────────────────────────────────────────────────────────

  /// SUPER_ADMIN sees all; ADMIN sees only their country's organizers.
  Future<PagedResponse<User>> getAllOrganizers({
    int page = 0,
    int size = 20,
  }) async {
    final body = await _api.get('/organizers', queryParams: {
      'page': page,
      'size': size,
    });
    return PagedResponse<User>.fromJson(
      body['data'] as Map<String, dynamic>,
      (j) => User.fromJson(j),
    );
  }

  /// Organizers created by the authenticated admin (from JWT).
  Future<List<User>> getMyOrganizers() async {
    final body = await _api.get('/organizers/my');
    final data = body['data'] as List<dynamic>? ?? [];
    return data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// SUPER_ADMIN: organizers created by a specific admin.
  Future<List<User>> getOrganizersByAdmin(String adminId) async {
    final body = await _api.get('/organizers/by-admin/$adminId');
    final data = body['data'] as List<dynamic>? ?? [];
    return data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<User> createOrganizer(CreateOrganizerRequest request) async {
    final body = await _api.post('/organizers', data: request.toJson());
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Get / Update by ID ────────────────────────────────────────────────────

  Future<User> getOrganizerById(String id) async {
    final body = await _api.get('/organizers/$id');
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<User> updateOrganizer(
      String id, UpdateOrganizerRequest request) async {
    final body = await _api.put('/organizers/$id', data: request.toJson());
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── My profile (ORGANIZER role) ───────────────────────────────────────────

  Future<User> getMyProfile() async {
    final body = await _api.get('/organizers/me');
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<User> updateMyProfile(UpdateOrganizerRequest request) async {
    final body = await _api.put('/organizers/me', data: request.toJson());
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<User> changeMyPassword(ChangePasswordRequest request) async {
    final body =
        await _api.put('/organizers/me/change-password', data: request.toJson());
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Block / Unblock ───────────────────────────────────────────────────────

  Future<User> blockOrganizer(String id) async {
    final body = await _api.put('/organizers/$id/block');
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<User> unblockOrganizer(String id) async {
    final body = await _api.put('/organizers/$id/unblock');
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }
}
