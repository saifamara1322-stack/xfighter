import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/tournament_model.dart';
import 'package:xfighter/data/models/user_model.dart';

/// Repository for all /api/tournaments endpoints.
class TournamentRepository {
  final ApiClient _api = ApiClient();

  // ── List ──────────────────────────────────────────────────────────────────

  Future<PagedResponse<Tournament>> getTournaments({
    int page = 0,
    int size = 20,
  }) async {
    final body = await _api.get('/tournaments', queryParams: {
      'page': page,
      'size': size,
    });
    return PagedResponse<Tournament>.fromJson(
      body['data'] as Map<String, dynamic>,
      (j) => Tournament.fromJson(j),
    );
  }

  // ── Single ────────────────────────────────────────────────────────────────

  Future<Tournament> getTournamentById(String id) async {
    final body = await _api.get('/tournaments/$id');
    return Tournament.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<Tournament> createTournament(CreateTournamentRequest request) async {
    final body = await _api.post('/tournaments', data: request.toJson());
    return Tournament.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<Tournament> updateTournament(
      String id, UpdateTournamentRequest request) async {
    final body = await _api.put('/tournaments/$id', data: request.toJson());
    return Tournament.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteTournament(String id) async {
    await _api.delete('/tournaments/$id');
  }

  // ── Status lifecycle ──────────────────────────────────────────────────────

  Future<Tournament> openRegistrations(String id) async {
    final body = await _api.patch('/tournaments/$id/open-registrations');
    return Tournament.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Tournament> closeRegistrations(String id) async {
    final body = await _api.patch('/tournaments/$id/close-registrations');
    return Tournament.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Tournament> reopenRegistrations(String id, {String? reason}) async {
    final body = await _api.patch('/tournaments/$id/reopen-registrations',
        data: reason != null ? {'reason': reason} : null);
    return Tournament.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Tournament> startTournament(String id, {String? reason}) async {
    final body = await _api.patch('/tournaments/$id/start',
        data: reason != null ? {'reason': reason} : null);
    return Tournament.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Tournament> completeTournament(String id, {String? reason}) async {
    final body = await _api.patch('/tournaments/$id/complete',
        data: reason != null ? {'reason': reason} : null);
    return Tournament.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getLifecycleEvents(String id) async {
    final body = await _api.get('/tournaments/$id/lifecycle-events');
    final data = body['data'] as List<dynamic>? ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  /// Change tournament status (legacy fallback).
  Future<Tournament> changeStatus(String id, String newStatus) async {
    final body = await _api.put('/tournaments/$id',
        data: UpdateTournamentRequest(status: newStatus).toJson());
    return Tournament.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Divisions ─────────────────────────────────────────────────────────────

  Future<List<TournamentDivision>> getDivisions(String id) async {
    final body = await _api.get('/tournaments/$id/divisions');
    final data = body['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => TournamentDivision.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TournamentDivision> addDivision(
      String id, CreateTournamentDivisionRequest request) async {
    final body = await _api.post('/tournaments/$id/divisions',
        data: request.toJson());
    return TournamentDivision.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Rules ─────────────────────────────────────────────────────────────────

  Future<List<TournamentRule>> getRules(String id) async {
    final body = await _api.get('/tournaments/$id/rules');
    final data = body['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => TournamentRule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TournamentRule> addRule(
      String id, CreateTournamentRuleRequest request) async {
    final body =
        await _api.post('/tournaments/$id/rules', data: request.toJson());
    return TournamentRule.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Registrations ─────────────────────────────────────────────────────────

  Future<List<TournamentRegistration>> getRegistrations(String id) async {
    final body = await _api.get('/tournaments/$id/registrations');
    final data = body['data'] as List<dynamic>? ?? [];
    return data
        .map((e) =>
            TournamentRegistration.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TournamentRegistration> registerAthlete(
      String id, CreateTournamentRegistrationRequest request) async {
    final body = await _api.post('/tournaments/$id/registrations',
        data: request.toJson());
    return TournamentRegistration.fromJson(
        body['data'] as Map<String, dynamic>);
  }

  Future<TournamentRegistration> approveRegistration(String registrationId) async {
    final body = await _api.patch(
        '/tournaments/registrations/$registrationId/approve');
    return TournamentRegistration.fromJson(
        body['data'] as Map<String, dynamic>);
  }

  Future<TournamentRegistration> rejectRegistration(
      String registrationId, String reason) async {
    final body = await _api.patch(
        '/tournaments/registrations/$registrationId/reject',
        data: {'reason': reason});
    return TournamentRegistration.fromJson(
        body['data'] as Map<String, dynamic>);
  }

  Future<TournamentRegistration> cancelRegistration(
      String registrationId) async {
    final body = await _api.patch(
        '/tournaments/registrations/$registrationId/cancel');
    return TournamentRegistration.fromJson(
        body['data'] as Map<String, dynamic>);
  }
}
