import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/data/models/coach_model.dart';
import 'package:xfighter/data/models/club_model.dart';

class FighterRepository {
  final ApiClient _api = ApiClient();

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<Fighter> getFighterProfile(String fighterId) async {
    final body = await _api.get('/fighter/$fighterId');
    return Fighter.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Coach> getFighterCoach(String fighterId) async {
    final body = await _api.get('/fighter/$fighterId/coach');
    return Coach.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<Club>> getFighterClubs(String fighterId) async {
    final body = await _api.get('/fighter/$fighterId/clubs');
    final data = body['data'] as List<dynamic>? ?? [];
    return data.map((e) => Club.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Club membership ────────────────────────────────────────────────────────

  Future<void> requestJoinClub(String clubId) async {
    await _api.post('/fighter/request-join-club/$clubId');
  }

  Future<void> respondToClubInvitation(
      String membershipId, String action) async {
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

  Future<void> respondToCoachRequest(
      String requestId, String action) async {
    await _api.put('/fighter/respond-coach-request/$requestId',
        data: {'action': action});
  }

  Future<void> cancelCoachRequest(String requestId) async {
    await _api.delete('/fighter/cancel-coach-request/$requestId');
  }
}