import 'api_client.dart';
import '../models/event_model.dart';

class RegistrationRepository {
  final ApiClient _apiClient = ApiClient();
  
  Future<List<EventRegistration>> getRegistrationsByEvent(String eventId) async {
    try {
      final response = await _apiClient.get('eventRegistrations?eventId=$eventId');
      if (response is List) {
        return response.map((json) => EventRegistration.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load registrations: $e');
    }
  }
  
  Future<List<EventRegistration>> getRegistrationsByFighter(String fighterId) async {
    try {
      final response = await _apiClient.get('eventRegistrations?fighterId=$fighterId');
      if (response is List) {
        return response.map((json) => EventRegistration.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load fighter registrations: $e');
    }
  }
  
  Future<List<EventRegistration>> getPendingRegistrationsByCoach(String coachId) async {
    try {
      // Get all fighters under this coach
      final fightersResponse = await _apiClient.get('fighters?coachId=$coachId');
      if (fightersResponse is! List) return [];
      
      final fighterIds = fightersResponse.map((f) => f['id'].toString()).toList();
      if (fighterIds.isEmpty) return [];
      
      // Get pending registrations for these fighters
      final allRegistrations = <EventRegistration>[];
      for (var fighterId in fighterIds) {
        final response = await _apiClient.get('eventRegistrations?fighterId=$fighterId&status=pending');
        if (response is List) {
          allRegistrations.addAll(response.map((json) => EventRegistration.fromJson(json)));
        }
      }
      
      return allRegistrations;
    } catch (e) {
      throw Exception('Failed to load pending registrations: $e');
    }
  }
  
  Future<EventRegistration> createRegistration(Map<String, dynamic> data) async {
    try {
      final newRegistration = {
        ...data,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'status': 'pending',
        'registeredAt': DateTime.now().toIso8601String(),
      };
      
      final response = await _apiClient.post('eventRegistrations', newRegistration);
      return EventRegistration.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create registration: $e');
    }
  }
  
  Future<EventRegistration> updateRegistrationStatus(
    String id, 
    String status, 
    String? actorId,
    {String? rejectionReason}
  ) async {
    try {
      final response = await _apiClient.get('eventRegistrations/$id');
      if (response == null) throw Exception('Registration not found');
      
      final updatedData = {
        ...response,
        'status': status,
        if (status == 'approved') 'approvedBy': actorId,
        if (status == 'approved') 'approvedAt': DateTime.now().toIso8601String(),
        if (status == 'rejected' && rejectionReason != null) 'rejectionReason': rejectionReason,
      };
      
      final result = await _apiClient.put('eventRegistrations/$id', updatedData);
      return EventRegistration.fromJson(result);
    } catch (e) {
      throw Exception('Failed to update registration status: $e');
    }
  }
  
  Future<EligibilityCheck> checkEligibility(String fighterId, String eventId, String weightClass) async {
    final reasons = <String>[];
    
    try {
      // Get fighter data
      final fighterResponse = await _apiClient.get('fighters?userId=$fighterId');
      if (fighterResponse is! List || fighterResponse.isEmpty) {
        reasons.add('Profil de combattant incomplet');
        return EligibilityCheck(isEligible: false, reasons: reasons);
      }
      
      final fighter = fighterResponse[0];
      
      // Check weight class
      final fighterWeight = int.parse(fighter['weight'].toString());
      final weightClassLimits = _getWeightClassLimits(weightClass);
      
      final minWeight = weightClassLimits['min'] as int;
      final maxWeight = weightClassLimits['max'] as int;
      
      if (fighterWeight < minWeight || fighterWeight > maxWeight) {
        reasons.add('Poids ne correspond pas à la catégorie $weightClass');
      }
      
      // Check if fighter is verified
      if (fighter['verified'] != true) {
        reasons.add('Profil de combattant non vérifié');
      }
      
      // Check if fighter is active
      final userResponse = await _apiClient.get('users/${fighter['userId']}');
      if (userResponse != null && userResponse['status'] != 'active') {
        reasons.add('Compte utilisateur non actif');
      }
      
      // Check if already registered for this event
      final existingRegistrations = await _apiClient.get('eventRegistrations?fighterId=$fighterId&eventId=$eventId');
      if (existingRegistrations is List && existingRegistrations.isNotEmpty) {
        reasons.add('Déjà inscrit à cet événement');
      }
      
      // Check event capacity
      final eventResponse = await _apiClient.get('events/$eventId');
      if (eventResponse != null && eventResponse['maxFighters'] > 0) {
        final registrationsResponse = await _apiClient.get('eventRegistrations?eventId=$eventId');
        if (registrationsResponse is List) {
          final approvedCount = registrationsResponse.where((r) => 
            r['status'] == 'approved'
          ).length;
          
          if (approvedCount >= eventResponse['maxFighters']) {
            reasons.add('Événement complet');
          }
        }
      }
      
      return EligibilityCheck(
        isEligible: reasons.isEmpty,
        reasons: reasons,
      );
    } catch (e) {
      reasons.add('Erreur de vérification: $e');
      return EligibilityCheck(isEligible: false, reasons: reasons);
    }
  }
  
  Map<String, dynamic> _getWeightClassLimits(String weightClass) {
    final Map<String, Map<String, int>> limits = {
      'Flyweight': {'min': 52, 'max': 57},
      'Bantamweight': {'min': 57, 'max': 61},
      'Featherweight': {'min': 61, 'max': 66},
      'Lightweight': {'min': 66, 'max': 70},
      'Welterweight': {'min': 70, 'max': 77},
      'Middleweight': {'min': 77, 'max': 84},
      'Light Heavyweight': {'min': 84, 'max': 93},
      'Heavyweight': {'min': 93, 'max': 120},
    };
    
    return limits[weightClass] ?? {'min': 0, 'max': 999};
  }

  // ADD THIS METHOD - Delete registration
  Future<void> deleteRegistration(String registrationId) async {
    try {
      await _apiClient.delete('eventRegistrations/$registrationId');
    } catch (e) {
      throw Exception('Failed to delete registration: $e');
    }
  }
  
  // ADD THIS METHOD - Get event by ID
  Future<Event?> getEventById(String eventId) async {
    try {
      final response = await _apiClient.get('events/$eventId');
      if (response != null) {
        return Event.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load event: $e');
    }
  }
}