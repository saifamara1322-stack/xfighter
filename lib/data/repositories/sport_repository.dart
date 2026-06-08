import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/sport_model.dart';

/// Repository for all /api/sports endpoints.
class SportRepository {
  final ApiClient _api = ApiClient();

  // ── List ──────────────────────────────────────────────────────────────────

  Future<List<Sport>> getSports() async {
    final body = await _api.get('/sports');
    final data = body['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => Sport.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Single ────────────────────────────────────────────────────────────────

  Future<Sport> getSportById(String id) async {
    final body = await _api.get('/sports/$id');
    return Sport.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<Sport> createSport(CreateSportRequest request) async {
    final body = await _api.post('/sports', data: request.toJson());
    return Sport.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<Sport> updateSport(String id, CreateSportRequest request) async {
    final body = await _api.put('/sports/$id', data: request.toJson());
    return Sport.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteSport(String id) async {
    await _api.delete('/sports/$id');
  }

  // ── Sport Category Rules ───────────────────────────────────────────────────

  Future<List<SportCategory>> getSportCategories(String sportId) async {
    final body = await _api.get('/sports/$sportId/categories');
    final data = body['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => SportCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SportCategory> attachCategory(
      String sportId, CreateSportCategoryRuleRequest request) async {
    final body = await _api.post('/sports/$sportId/categories',
        data: request.toJson());
    return SportCategory.fromJson(body['data'] as Map<String, dynamic>);
  }
}
