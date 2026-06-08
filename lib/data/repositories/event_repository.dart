// This file is kept as a thin compatibility shim.
// All real tournament data is handled by TournamentRepository.
// Legacy EventController references still compile via the Event model below.

import 'package:xfighter/data/models/event_model.dart';
import 'package:xfighter/data/repositories/tournament_repository.dart';
import 'package:xfighter/data/models/tournament_model.dart';
import 'package:xfighter/data/models/user_model.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';
 
export 'package:xfighter/data/repositories/tournament_repository.dart';

/// Compatibility shim — delegates to TournamentRepository.
class EventRepository {
  final TournamentRepository _repo = TournamentRepository();
  final AuthController _authController = Get.find<AuthController>();

  Future<List<Event>> getAllEvents({Map<String, dynamic>? queryParams}) async {
    try {
      final paged = await _repo.getTournaments(page: 0, size: 50);
      return paged.content.map(_toEvent).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Event> getEventById(String eventId) async {
    final t = await _repo.getTournamentById(eventId);
    return _toEvent(t);
  }

  /// Creates a tournament using the new API schema.
  /// Expected map keys:
  /// - name (String)
  /// - description (String?, optional)
  /// - level (String) e.g. 'LOCAL', 'REGIONAL', etc.
  /// - countryId (String)
  /// - city (String)
  /// - venue (String)
  /// - startDate (String ISO date) or 'date' (legacy)
  /// - endDate (String ISO date)
  /// - registrationOpenAt (String ISO datetime)
  /// - registrationCloseAt (String ISO datetime)
  /// - organizerId (String, optional; will use logged-in user if not provided)
  Future<Event> createEvent(Map<String, dynamic> data) async {
    final organizerId = data['organizerId'] ?? _authController.currentUser.value?.id;
    if (organizerId == null) {
      throw Exception('Organizer ID is required to create a tournament.');
    }

    // Handle both legacy and new field names
    final startDateStr = data['startDate'] ?? data['date'];
    final endDateStr = data['endDate'] ?? data['date']; // fallback, but better to have endDate

    final request = CreateTournamentRequest(
      name: data['name'] ?? 'New Tournament',
      description: data['description'],
      level: data['level'] ?? 'LOCAL',
      countryId: data['countryId'] ?? '', // must be provided
      organizerId: organizerId,
      city: data['city'] ?? data['location'] ?? '', // fallback to legacy 'location'
      venue: data['venue'] ?? data['location'] ?? '', // fallback
      startDate: startDateStr ?? DateTime.now().toIso8601String(),
      endDate: endDateStr ?? DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      registrationOpenAt: data['registrationOpenAt'] ?? startDateStr ?? DateTime.now().toIso8601String(),
      registrationCloseAt: data['registrationCloseAt'] ?? endDateStr ?? DateTime.now().add(const Duration(days: 1)).toIso8601String(),
    );
    final t = await _repo.createTournament(request);
    return _toEvent(t);
  }

  Future<Event> updateEvent(String eventId, Map<String, dynamic> data) async {
    // Map legacy fields to new API fields as needed
    final request = UpdateTournamentRequest(
      name: data['name'],
      description: data['description'],
      level: data['level'],
      countryId: data['countryId'],
      city: data['city'] ?? data['location'],
      venue: data['venue'] ?? data['location'],
      startDate: data['startDate'] ?? data['date'],
      endDate: data['endDate'],
      registrationOpenAt: data['registrationOpenAt'],
      registrationCloseAt: data['registrationCloseAt'],
      status: data['status'],
    );
    final t = await _repo.updateTournament(eventId, request);
    return _toEvent(t);
  }

  Future<void> deleteEvent(String eventId) async {
    await _repo.deleteTournament(eventId);
  }

  /// Converts the new Tournament model to the legacy Event model.
  Event _toEvent(Tournament t) => Event(
        id: t.id,
        name: t.name,
        date: t.startDate, // using startDate as the main date
        location: t.city,  // map city to location for compatibility
        venue: t.venue,
        organizerId: t.organizerId,
        description: t.description,
      );
}