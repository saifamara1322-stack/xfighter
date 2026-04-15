import 'api_client.dart';
import '../models/gym_model.dart';
import '../models/fighter_model.dart';

class GymRepository {
  final ApiClient _apiClient = ApiClient();
  
  Future<List<Gym>> getAllGyms() async {
    try {
      final response = await _apiClient.get('gyms');
      if (response is List) {
        return response.map((json) => Gym.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load gyms: $e');
    }
  }
  
  Future<List<Gym>> getActiveGyms() async {
    try {
      final response = await _apiClient.get('gyms?status=active');
      if (response is List) {
        return response.map((json) => Gym.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load active gyms: $e');
    }
  }
  
  Future<Gym?> getGymById(String id) async {
    try {
      final response = await _apiClient.get('gyms/$id');
      if (response != null) {
        return Gym.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load gym: $e');
    }
  }
  
  Future<List<Gym>> getGymsByOwner(String ownerId) async {
    try {
      final response = await _apiClient.get('gyms?ownerId=$ownerId');
      if (response is List) {
        return response.map((json) => Gym.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load owner gyms: $e');
    }
  }
  
  Future<Gym> createGym(Map<String, dynamic> gymData) async {
    try {
      final newGym = {
        ...gymData,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'status': 'pending',
        'verified': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'fighters': [],
      };
      
      final response = await _apiClient.post('gyms', newGym);
      return Gym.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create gym: $e');
    }
  }
  
  Future<Gym> updateGym(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('gyms/$id', data);
      return Gym.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update gym: $e');
    }
  }
  
  Future<Gym> updateGymStatus(String id, String status, String? adminId, String? comments) async {
    try {
      final gym = await getGymById(id);
      if (gym == null) throw Exception('Gym not found');
      
      final updatedData = {
        ...gym.toJson(),
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
        'verified': status == 'active',
      };
      
      final response = await _apiClient.put('gyms/$id', updatedData);
      return Gym.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update gym status: $e');
    }
  }
  
  Future<Gym> addFighterToGym(String gymId, String fighterId) async {
    try {
      final gym = await getGymById(gymId);
      if (gym == null) throw Exception('Gym not found');
      
      if (!gym.fighters.contains(fighterId)) {
        final updatedFighters = [...gym.fighters, fighterId];
        final updatedData = {
          ...gym.toJson(),
          'fighters': updatedFighters,
          'updatedAt': DateTime.now().toIso8601String(),
        };
        
        final response = await _apiClient.put('gyms/$gymId', updatedData);
        return Gym.fromJson(response);
      }
      return gym;
    } catch (e) {
      throw Exception('Failed to add fighter to gym: $e');
    }
  }
  
  Future<Gym> removeFighterFromGym(String gymId, String fighterId) async {
    try {
      final gym = await getGymById(gymId);
      if (gym == null) throw Exception('Gym not found');
      
      final updatedFighters = gym.fighters.where((id) => id != fighterId).toList();
      final updatedData = {
        ...gym.toJson(),
        'fighters': updatedFighters,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      final response = await _apiClient.put('gyms/$gymId', updatedData);
      return Gym.fromJson(response);
    } catch (e) {
      throw Exception('Failed to remove fighter from gym: $e');
    }
  }
  
  Future<List<Fighter>> getGymFighters(String gymId) async {
    try {
      final gym = await getGymById(gymId);
      if (gym == null) return [];
      
      final fighters = <Fighter>[];
      for (var fighterId in gym.fighters) {
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
      throw Exception('Failed to load gym fighters: $e');
    }
  }
}