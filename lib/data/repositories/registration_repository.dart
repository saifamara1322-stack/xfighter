import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/enhanced_event_registration.dart';

class RegistrationRepository {
  final ApiClient _api = ApiClient();

  // ── Fighter registrations ─────────────────────────────────────────────────

  Future<List<EnhancedEventRegistration>> getFighterRegistrations({
    required String fighterId,
  }) async {
    try {
      final body = await _api.get('/registrations/fighter/$fighterId');
      final data = body['data'] as List<dynamic>? ?? [];
      return data
          .map((e) =>
              EnhancedEventRegistration.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Coach registrations ───────────────────────────────────────────────────

  Future<List<EnhancedEventRegistration>> getCoachPendingRegistrations({
    required String coachId,
  }) async {
    try {
      final body = await _api.get('/registrations/coach/$coachId/pending');
      final data = body['data'] as List<dynamic>? ?? [];
      return data
          .map((e) =>
              EnhancedEventRegistration.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Organizer registrations ───────────────────────────────────────────────

  Future<List<EnhancedEventRegistration>> getOrganizerPendingRegistrations({
    required String organizerId,
  }) async {
    try {
      final body =
          await _api.get('/registrations/organizer/$organizerId/pending');
      final data = body['data'] as List<dynamic>? ?? [];
      return data
          .map((e) =>
              EnhancedEventRegistration.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<bool> registerForEvent(EnhancedEventRegistration registration) async {
    try {
      await _api.post('/registrations', data: registration.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Approval / rejection ──────────────────────────────────────────────────

  Future<bool> approveByCoach({
    required String registrationId,
    required String coachId,
    String? notes,
  }) async {
    try {
      await _api.put('/registrations/$registrationId/approve-coach',
          data: {'coachId': coachId, if (notes != null) 'notes': notes});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> approveByOrganizer({
    required String registrationId,
    required String organizerId,
    String? notes,
  }) async {
    try {
      await _api.put('/registrations/$registrationId/approve-organizer',
          data: {
            'organizerId': organizerId,
            if (notes != null) 'notes': notes
          });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectRegistration({
    required String registrationId,
    required String rejectedBy,
    required String reason,
  }) async {
    try {
      await _api.put('/registrations/$registrationId/reject',
          data: {'rejectedBy': rejectedBy, 'reason': reason});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelRegistration(String registrationId) async {
    try {
      await _api.delete('/registrations/$registrationId');
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Eligibility ───────────────────────────────────────────────────────────

  Future<EligibilityCheck> checkEligibility({
    required String fighterId,
    required String eventId,
  }) async {
    try {
      final body = await _api.get(
          '/registrations/eligibility',
          queryParams: {'fighterId': fighterId, 'eventId': eventId});
      return EligibilityCheck.fromJson(
          body['data'] as Map<String, dynamic>? ?? {});
    } catch (_) {
      return EligibilityCheck(isEligible: false, reason: 'Check failed');
    }
  }

  // ── Event details ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getEventDetails(String eventId) async {
    try {
      final body = await _api.get('/events/$eventId');
      return body['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}

// Local model re-exported for controller convenience
class EligibilityCheck {
  final bool isEligible;
  final String? reason;
  final Map<String, dynamic>? details;

  EligibilityCheck({
    required this.isEligible,
    this.reason,
    this.details,
  });

  factory EligibilityCheck.fromJson(Map<String, dynamic> json) =>
      EligibilityCheck(
        isEligible: json['isEligible'] ?? false,
        reason: json['reason'],
        details: json['details'] as Map<String, dynamic>?,
      );
}
