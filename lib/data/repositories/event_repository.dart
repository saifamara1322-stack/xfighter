import 'package:xfighter/data/models/event_model.dart';

class EventRepository {
  // Use dummy data since the API docs do not define event endpoints yet
  final List<Event> _dummyEvents = [
    Event(
      id: '1',
      name: 'X-Fighter Championship I',
      date: DateTime.now().add(const Duration(days: 14)),
      location: 'Grand Arena',
      venue: 'Paris, France',
      organizerId: 'org-123',
      description: 'The biggest MMA event of the year.',
    ),
    Event(
      id: '2',
      name: 'Amateur Fight Night',
      date: DateTime.now().add(const Duration(days: 30)),
      location: 'Local Gym',
      venue: 'Lyon, France',
      organizerId: 'org-456',
      description: 'A great opportunity for upcoming fighters.',
    ),
  ];

  Future<List<Event>> getAllEvents({Map<String, dynamic>? queryParams}) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network latency
    return List.from(_dummyEvents);
  }

  Future<Event> getEventById(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyEvents.firstWhere(
      (e) => e.id == eventId,
      orElse: () => throw Exception('Event not found'),
    );
  }

  Future<Event> createEvent(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final newEvent = Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: data['name'] ?? 'New Event',
      date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now().add(const Duration(days: 7)),
      location: data['location'] ?? 'TBD',
      venue: data['venue'] ?? 'TBD',
      organizerId: data['organizerId'] ?? 'unknown',
      description: data['description'],
    );
    
    _dummyEvents.insert(0, newEvent);
    return newEvent;
  }

  Future<Event> updateEvent(String eventId, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final index = _dummyEvents.indexWhere((e) => e.id == eventId);
    if (index == -1) throw Exception('Event not found');
    
    final current = _dummyEvents[index];
    final updated = Event(
      id: current.id,
      name: data['name'] ?? current.name,
      date: data['date'] != null ? DateTime.parse(data['date']) : current.date,
      location: data['location'] ?? current.location,
      venue: data['venue'] ?? current.venue,
      organizerId: current.organizerId,
      description: data['description'] ?? current.description,
    );
    
    _dummyEvents[index] = updated;
    return updated;
  }

  Future<void> deleteEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _dummyEvents.removeWhere((e) => e.id == eventId);
  }
}
