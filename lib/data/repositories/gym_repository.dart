import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/gym_model.dart';
import 'package:xfighter/data/models/fighter_model.dart';

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
  
  Future<Gym> getGymById(String id) async {
    try {
      final response = await _apiClient.get('gyms/$id');
      return Gym.fromJson(response);
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
      throw Exception('Failed to load gyms: $e');
    }
  }
  
  Future<Gym> createGym(Map<String, dynamic> gymData) async {
    try {
      final newGym = {
        ...gymData,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
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
  
  Future<List<Fighter>> getGymFighters(String gymId) async {
    try {
      final response = await _apiClient.get('fighters?gym=$gymId');
      if (response is List) {
        return response.map((json) => Fighter.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load gym fighters: $e');
    }
  }
}