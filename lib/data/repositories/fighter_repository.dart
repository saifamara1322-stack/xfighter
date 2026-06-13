import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/data/models/coach_model.dart';   // full Coach model
import 'package:xfighter/data/models/club_model.dart';     // full Club model

class FighterRepository {
  final ApiClient _api = ApiClient();

  /// Get fighter profile using the user's ID (not fighter ID)
  Future<Fighter> getFighterByUserId(String userId) async {
    final responseBody = await _api.get('/fighter/by-user/$userId');
    print('🔍 Full API response: $responseBody');
    
    // Ensure we extract the 'data' field
    final data = responseBody['data'];
    if (data == null) {
      throw Exception('Response missing "data" field: $responseBody');
    }
    if (data is! Map<String, dynamic>) {
      throw Exception('"data" is not a Map: $data');
    }
    
    return Fighter.fromJson(data);
  }

// fighter_repository.dart
Future<List<Club>> getAllClubs() async {
  final response = await _api.get('/club/all');
  // Assuming the response contains 'data' field with the list
  final data = response['data'];
  if (data is List) {
    return data.map((e) => Club.fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
}

  /// Get full coach details by fighter ID
  Future<Coach> getFighterCoach(String fighterId) async {
    final body = await _api.get('/fighter/$fighterId/coach');
    return Coach.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Get list of clubs for a fighter (by fighter ID)
  Future<List<Club>> getFighterClubs(String fighterId) async {
    final body = await _api.get('/fighter/$fighterId/clubs');
    final data = body['data'] as List<dynamic>? ?? [];
    return data.map((e) => Club.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Club membership ────────────────────────────────────────────────────────
  Future<void> requestJoinClub(String clubId) async {
    await _api.post('/fighter/request-join-club/$clubId');
  }

  Future<void> respondToClubInvitation(String membershipId, String action) async {
    await _api.put('/fighter/respond-club-invitation/$membershipId',
        data: {'action': action});
  }

  Future<void> cancelClubRequest(String membershipId) async {
    await _api.delete('/fighter/cancel-club-request/$membershipId');
  }

  // ── Coach relationship ─────────────────────────────────────────────────────
  Future<void> requestCoach(String coachId) async {
    await _api.post('/fighter/request-coach/$coachId');
  }

  Future<void> respondToCoachRequest(String requestId, String action) async {
    await _api.put('/fighter/respond-coach-request/$requestId',
        data: {'action': action});
  }

  Future<void> cancelCoachRequest(String requestId) async {
    await _api.delete('/fighter/cancel-coach-request/$requestId');
  }
}