import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/club_model.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/data/models/coach_model.dart';

class ClubRepository {
  final ApiClient _api = ApiClient();

  // ── Listing ────────────────────────────────────────────────────────────────

  Future<PagedClubResponse> getAllClubs({String? status}) async {
    final body = await _api.get('/club/all',
        queryParams: status != null ? {'status': status} : null);
    return PagedClubResponse.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Club> getClubById(String clubId) async {
    final body = await _api.get('/club/$clubId');
    return Club.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Club> getClubProfile(String clubId) async {
    final body = await _api.get('/club/$clubId/profile');
    return Club.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Club> getMyClub() async {
    final body = await _api.get('/club/my-club');
    return Club.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Members ────────────────────────────────────────────────────────────────

  Future<List<Fighter>> getClubFighters(String clubId) async {
    final body = await _api.get('/club/$clubId/fighters');
    final data = body['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => Fighter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Coach>> getClubCoaches(String clubId) async {
    final body = await _api.get('/club/$clubId/coaches');
    final data = body['data'] as List<dynamic>? ?? [];
    return data.map((e) => Coach.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Create / Update ────────────────────────────────────────────────────────

  Future<Club> createClub(Map<String, dynamic> data) async {
    final body = await _api.post('/club/create', data: data);
    return Club.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Club> updateMyClub(Map<String, dynamic> data) async {
    final body = await _api.put('/club/my-club', data: data);
    return Club.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Club> updateClubLogo(String clubId, String logoUrl) async {
    final body = await _api.put('/club/$clubId/logo',
        data: {'logoUrl': logoUrl});
    return Club.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Fighters ───────────────────────────────────────────────────────────────

  Future<Fighter> addFighterToClub(
      String clubId, Map<String, dynamic> data) async {
    final body = await _api.post('/club/$clubId/fighters', data: data);
    return Fighter.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> removeFighterFromClub(
      String clubId, String fighterId) async {
    await _api.delete('/club/$clubId/fighters/$fighterId');
  }

  Future<void> verifyFighter(String fighterId) async {
    await _api.put('/club/verify-fighter/$fighterId');
  }

  // ── Invitations ────────────────────────────────────────────────────────────

  Future<void> inviteFighter(String fighterId) async {
    await _api.post('/club/invite-fighter/$fighterId');
  }

  Future<void> inviteCoach(String coachId) async {
    await _api.post('/club/invite-coach/$coachId');
  }

  Future<void> cancelFighterInvitation(String membershipId) async {
    await _api.delete('/club/cancel-fighter-invitation/$membershipId');
  }

  Future<void> cancelCoachInvitation(String membershipId) async {
    await _api.delete('/club/cancel-coach-invitation/$membershipId');
  }

  // ── Membership requests ────────────────────────────────────────────────────

  Future<void> respondToFighterRequest(
      String membershipId, String action) async {
    await _api.put('/club/respond-fighter-request/$membershipId',
        data: {'action': action});
  }

  Future<void> respondToCoachRequest(
      String membershipId, String action) async {
    await _api.put('/club/respond-coach-request/$membershipId',
        data: {'action': action});
  }

  // ── Status management ──────────────────────────────────────────────────────

  Future<void> blockClub(String clubId) async {
    await _api.put('/club/$clubId/block');
  }

  Future<void> activateClub(String clubId) async {
    await _api.put('/club/$clubId/activate');
  }
}

// Legacy alias so old GymRepository references still compile
@Deprecated('Use ClubRepository instead')
typedef GymRepository = ClubRepository;
