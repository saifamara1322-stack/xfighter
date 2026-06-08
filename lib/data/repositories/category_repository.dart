import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/category_model.dart';

/// Repository for all /api/categories endpoints.
class CategoryRepository {
  final ApiClient _api = ApiClient();

  // ── List ──────────────────────────────────────────────────────────────────

  Future<List<Category>> getCategories() async {
    final body = await _api.get('/categories');
    final data = body['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Single ────────────────────────────────────────────────────────────────

  Future<Category> getCategoryById(String id) async {
    final body = await _api.get('/categories/$id');
    return Category.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<Category> createCategory(CreateCategoryRequest request) async {
    final body = await _api.post('/categories', data: request.toJson());
    return Category.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<Category> updateCategory(
      String id, CreateCategoryRequest request) async {
    final body = await _api.put('/categories/$id', data: request.toJson());
    return Category.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteCategory(String id) async {
    await _api.delete('/categories/$id');
  }
}
