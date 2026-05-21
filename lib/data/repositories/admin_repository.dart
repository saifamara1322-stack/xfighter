import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/user_model.dart';
import 'package:xfighter/data/models/admin_model.dart';

class AdminRepository {
  final ApiClient _api = ApiClient();

  // ── List ──────────────────────────────────────────────────────────────────

  /// SUPER_ADMIN: paginated list of all admins with optional filters.
  Future<PagedResponse<User>> getAllAdmins({
    int page = 0,
    int size = 20,
    String? countryId,
    String? status,
  }) async {
    final body = await _api.get('/admin', queryParams: {
      'page': page,
      'size': size,
      if (countryId != null) 'countryId': countryId,
      if (status != null) 'status': status,
    });
    return PagedResponse<User>.fromJson(
      body['data'] as Map<String, dynamic>,
      (j) => User.fromJson(j),
    );
  }

  // ── Create ────────────────────────────────────────────────────────────────

  /// SUPER_ADMIN creates a new admin (status set to ACTIVE automatically).
  Future<User> createAdmin(CreateAdminRequest request) async {
    final body = await _api.post('/admin', data: request.toJson());
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Get by ID ─────────────────────────────────────────────────────────────

  Future<User> getAdminById(String id) async {
    final body = await _api.get('/admin/$id');
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<User> updateAdmin(String id, UpdateAdminRequest request) async {
    final body = await _api.put('/admin/$id', data: request.toJson());
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── My profile ───────────────────────────────────────────────────────────

  Future<User> getMyProfile() async {
    final body = await _api.get('/admin/me');
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<User> updateMyProfile(UpdateAdminRequest request) async {
    final body = await _api.put('/admin/me', data: request.toJson());
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Password & Email ─────────────────────────────────────────────────────

  Future<User> changeMyPassword(ChangePasswordRequest request) async {
    final body = await _api.put('/admin/me/password', data: request.toJson());
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<User> changeMyEmail(ChangeEmailRequest request) async {
    final body = await _api.put('/admin/me/email', data: request.toJson());
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// SUPER_ADMIN changes any admin's password without requiring the old one.
  Future<User> changeAdminPassword(
      String id, ChangePasswordRequest request) async {
    final body =
        await _api.put('/admin/$id/password', data: request.toJson());
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// SUPER_ADMIN changes any admin's email.
  Future<User> changeAdminEmail(String id, ChangeEmailRequest request) async {
    final body = await _api.put('/admin/$id/email', data: request.toJson());
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Activate / Deactivate ────────────────────────────────────────────────

  Future<User> activateAdmin(String id) async {
    final body = await _api.put('/admin/$id/activate');
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<User> deactivateAdmin(String id) async {
    final body = await _api.put('/admin/$id/deactivate');
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Audit ─────────────────────────────────────────────────────────────────

  Future<AdminAuditResponse> getAdminAudit(String id) async {
    final body = await _api.get('/admin/$id/audit');
    return AdminAuditResponse.fromJson(
        body['data'] as Map<String, dynamic>);
  }
}
