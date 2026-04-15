import 'api_client.dart';
import '../models/event_model.dart';

class EventRepository {
  final ApiClient _apiClient = ApiClient();
  
  Future<List<Event>> getAllEvents() async {
    try {
      final response = await _apiClient.get('events');
      if (response is List) {
        return response.map((json) => Event.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }
  
  Future<List<Event>> getUpcomingEvents() async {
    try {
      final response = await _apiClient.get('events?status=upcoming');
      if (response is List) {
        return response.map((json) => Event.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load upcoming events: $e');
    }
  }
  
  Future<List<Event>> getEventsByOrganizer(String organizerId) async {
    try {
      final response = await _apiClient.get('events?organizerId=$organizerId');
      if (response is List) {
        return response.map((json) => Event.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load organizer events: $e');
    }
  }
  
  Future<List<Event>> getPendingEvents() async {
    try {
      final response = await _apiClient.get('events?status=pending');
      if (response is List) {
        return response.map((json) => Event.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load pending events: $e');
    }
  }
  
  Future<Event?> getEventById(String id) async {
    try {
      final response = await _apiClient.get('events/$id');
      if (response != null) {
        return Event.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load event: $e');
    }
  }
  
  Future<Event> createEvent(Map<String, dynamic> eventData) async {
    try {
      final newEvent = {
        ...eventData,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'status': 'pending',
        'fightCard': [],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      final response = await _apiClient.post('events', newEvent);
      return Event.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }
  
  Future<Event> updateEvent(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('events/$id', data);
      return Event.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }
  
  Future<Event> updateEventStatus(String id, String status, String? adminId) async {
    try {
      final event = await getEventById(id);
      if (event == null) throw Exception('Event not found');
      
      final updatedData = {
        ...event.toJson(),
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
        if (status == 'approved') ...{
          'approvedAt': DateTime.now().toIso8601String(),
          'approvedBy': adminId,
        }
      };
      
      final response = await _apiClient.put('events/$id', updatedData);
      return Event.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update event status: $e');
    }
  }
  
  Future<void> deleteEvent(String id) async {
    try {
      await _apiClient.delete('events/$id');
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }
  
  Future<List<EventRegistration>> getEventRegistrations(String eventId) async {
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
  
  Future<EventRegistration> registerFighter(Map<String, dynamic> registrationData) async {
    try {
      final newRegistration = {
        ...registrationData,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'registeredAt': DateTime.now().toIso8601String(),
        'status': 'pending',
      };
      
      final response = await _apiClient.post('eventRegistrations', newRegistration);
      return EventRegistration.fromJson(response);
    } catch (e) {
      throw Exception('Failed to register fighter: $e');
    }
  }
  
  Future<EventRegistration> updateRegistrationStatus(String id, String status, String? adminId) async {
    try {
      final response = await _apiClient.get('eventRegistrations/$id');
      if (response == null) throw Exception('Registration not found');
      
      final updatedData = {
        ...response,
        'status': status,
        if (status == 'approved') ...{
          'approvedBy': adminId,
          'approvedAt': DateTime.now().toIso8601String(),
        }
      };
      
      final result = await _apiClient.put('eventRegistrations/$id', updatedData);
      return EventRegistration.fromJson(result);
    } catch (e) {
      throw Exception('Failed to update registration: $e');
    }
  }
}