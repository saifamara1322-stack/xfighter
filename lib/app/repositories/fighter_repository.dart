import 'api_client.dart';
import '../models/fighter_model.dart';

class FighterRepository {
  final ApiClient _apiClient = ApiClient();
  
  Future<Fighter?> getFighterByUserId(String userId) async {
    try {
      final response = await _apiClient.get('fighters?userId=$userId');
      if (response is List && response.isNotEmpty) {
        return Fighter.fromJson(response[0]);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load fighter profile: $e');
    }
  }
  
  Future<Fighter> getFighterById(String id) async {
    try {
      final response = await _apiClient.get('fighters/$id');
      return Fighter.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load fighter: $e');
    }
  }
  
  Future<Fighter> createFighter(Map<String, dynamic> fighterData) async {
    try {
      final newFighter = {
        ...fighterData,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'record': {
          'wins': 0,
          'losses': 0,
          'draws': 0,
          'knockouts': 0,
          'submissions': 0,
          'decisions': 0,
        },
        'verified': false,
      };
      
      final response = await _apiClient.post('fighters', newFighter);
      return Fighter.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create fighter profile: $e');
    }
  }
  
  Future<Fighter> updateFighter(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('fighters/$id', data);
      return Fighter.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update fighter profile: $e');
    }
  }
  
  Future<List<Fighter>> getFightersByGym(String gym) async {
    try {
      final response = await _apiClient.get('fighters?gym=$gym');
      if (response is List) {
        return response.map((json) => Fighter.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load fighters: $e');
    }
  }
  
  Future<List<Fighter>> getRankings(String weightClass) async {
    try {
      final response = await _apiClient.get('fighters?weightClass=$weightClass&_sort=record.wins&_order=desc');
      if (response is List) {
        return response.map((json) => Fighter.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load rankings: $e');
    }
  }
}