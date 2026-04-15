import 'api_client.dart';
import '../models/coach_model.dart';
import '../models/fighter_model.dart';

class CoachRepository {
  final ApiClient _apiClient = ApiClient();
  
  Future<Coach?> getCoachByUserId(String userId) async {
    try {
      final response = await _apiClient.get('coaches?userId=$userId');
      if (response is List && response.isNotEmpty) {
        return Coach.fromJson(response[0]);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load coach profile: $e');
    }
  }
  
  Future<Coach?> getCoachById(String id) async {
    try {
      final response = await _apiClient.get('coaches/$id');
      if (response != null) {
        return Coach.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load coach: $e');
    }
  }
  
  Future<List<Coach>> getAllCoaches() async {
    try {
      final response = await _apiClient.get('coaches');
      if (response is List) {
        return response.map((json) => Coach.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load coaches: $e');
    }
  }
  
  Future<List<Coach>> getActiveCoaches() async {
    try {
      final response = await _apiClient.get('coaches?status=active');
      if (response is List) {
        return response.map((json) => Coach.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load active coaches: $e');
    }
  }
  
  Future<Coach> createCoach(Map<String, dynamic> coachData) async {
    try {
      final newCoach = {
        ...coachData,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'status': 'pending',
        'verified': false,
        'fighters': [],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      final response = await _apiClient.post('coaches', newCoach);
      return Coach.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create coach profile: $e');
    }
  }
  
  Future<Coach> updateCoach(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('coaches/$id', data);
      return Coach.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update coach profile: $e');
    }
  }
  
  Future<Coach> updateCoachStatus(String id, String status, String? adminId) async {
    try {
      final coach = await getCoachById(id);
      if (coach == null) throw Exception('Coach not found');
      
      final updatedData = {
        ...coach.toJson(),
        'status': status,
        'verified': status == 'active',
        'verifiedAt': status == 'active' ? DateTime.now().toIso8601String() : null,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      final response = await _apiClient.put('coaches/$id', updatedData);
      return Coach.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update coach status: $e');
    }
  }
  
  Future<Coach> addFighterToCoach(String coachId, String fighterId) async {
    try {
      final coach = await getCoachById(coachId);
      if (coach == null) throw Exception('Coach not found');
      
      if (!coach.fighters.contains(fighterId)) {
        final updatedFighters = [...coach.fighters, fighterId];
        final updatedData = {
          ...coach.toJson(),
          'fighters': updatedFighters,
          'updatedAt': DateTime.now().toIso8601String(),
        };
        
        final response = await _apiClient.put('coaches/$coachId', updatedData);
        return Coach.fromJson(response);
      }
      return coach;
    } catch (e) {
      throw Exception('Failed to add fighter to coach: $e');
    }
  }
  
  Future<Coach> removeFighterFromCoach(String coachId, String fighterId) async {
    try {
      final coach = await getCoachById(coachId);
      if (coach == null) throw Exception('Coach not found');
      
      final updatedFighters = coach.fighters.where((id) => id != fighterId).toList();
      final updatedData = {
        ...coach.toJson(),
        'fighters': updatedFighters,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      final response = await _apiClient.put('coaches/$coachId', updatedData);
      return Coach.fromJson(response);
    } catch (e) {
      throw Exception('Failed to remove fighter from coach: $e');
    }
  }
  
  Future<List<Fighter>> getCoachFighters(String coachId) async {
    try {
      final coach = await getCoachById(coachId);
      if (coach == null) return [];
      
      final fighters = <Fighter>[];
      for (var fighterId in coach.fighters) {
        try {
          final response = await _apiClient.get('fighters/$fighterId');
          if (response != null) {
            fighters.add(Fighter.fromJson(response));
          }
        } catch (e) {
          print('Error loading fighter $fighterId: $e');
        }
      }
      return fighters;
    } catch (e) {
      throw Exception('Failed to load coach fighters: $e');
    }
  }
}