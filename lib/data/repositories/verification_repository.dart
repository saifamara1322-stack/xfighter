import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/verification_model.dart';

class VerificationRepository {
  final ApiClient _api = ApiClient();

  // ── Pending lists ─────────────────────────────────────────────────────────

  /// All pending users (SuperAdmin: all; Admin/Organizer: only theirs).
  Future<PendingUserPage> getPendingUsers({int page = 0, int size = 20}) async {
    final body = await _api.get('/verification/pending', queryParams: {
      'page': page,
      'size': size,
    });
    return PendingUserPage.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Pending fighters only.
  Future<PendingUserPage> getPendingFighters(
      {int page = 0, int size = 20}) async {
    final body =
        await _api.get('/verification/pending/fighters', queryParams: {
      'page': page,
      'size': size,
    });
    return PendingUserPage.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Pending referees only.
  Future<PendingUserPage> getPendingReferees(
      {int page = 0, int size = 20}) async {
    final body =
        await _api.get('/verification/pending/referees', queryParams: {
      'page': page,
      'size': size,
    });
    return PendingUserPage.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Approve a pending user → sets status to ACTIVE.
  Future<void> approveUser(String userId) async {
    await _api.post('/verification/$userId/approve');
  }

  /// Reject a pending user with a reason note.
  Future<void> rejectUser(String userId, RejectionRequest request) async {
    await _api.post('/verification/$userId/reject', data: request.toJson());
  }

  // ── Documents ─────────────────────────────────────────────────────────────

  /// Get all uploaded document URLs for a user.
  Future<UserDocumentsResponse> getUserDocuments(String userId) async {
    final body = await _api.get('/verification/$userId/documents');
    return UserDocumentsResponse.fromJson(
        body['data'] as Map<String, dynamic>);
  }
}
