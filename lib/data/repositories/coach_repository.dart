import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/coach_model.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/data/models/club_model.dart';

class CoachRepository {
  final ApiClient _api = ApiClient();

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<List<Fighter>> getCoachFighters(String coachId) async {
    final body = await _api.get('/coach/$coachId/fighters');
    final data = body['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => Fighter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Club>> getCoachClubs(String coachId) async {
    final body = await _api.get('/coach/$coachId/clubs');
    final data = body['data'] as List<dynamic>? ?? [];
    return data.map((e) => Club.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Requests ───────────────────────────────────────────────────────────────

  Future<void> requestTrainFighter(String fighterId) async {
    await _api.post('/coach/request-train-fighter/$fighterId');
  }

  Future<void> requestJoinClub(String clubId) async {
    await _api.post('/coach/request-join-club/$clubId');
  }

  // ── Responses ──────────────────────────────────────────────────────────────

  Future<void> respondToClubInvitation(
      String membershipId, String action) async {
    await _api.put('/coach/respond-club-invitation/$membershipId',
        data: {'action': action});
  }

  Future<void> respondToFighterRequest(
      String requestId, String action) async {
    await _api.put('/coach/respond-fighter-request/$requestId',
        data: {'action': action});
  }

  // ── Cancellations ─────────────────────────────────────────────────────────

  Future<void> cancelClubRequest(String membershipId) async {
    await _api.delete('/coach/cancel-club-request/$membershipId');
  }

  Future<void> cancelFighterRequest(String requestId) async {
    await _api.delete('/coach/cancel-fighter-request/$requestId');
  }
}
