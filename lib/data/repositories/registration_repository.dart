import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/enhanced_event_registration.dart';

class RegistrationRepository {
  final ApiClient _api = ApiClient();

  // Helper to map API registration to UI model
  EnhancedEventRegistration _mapToEnhanced(Map<String, dynamic> r, [Map<String, dynamic>? t]) {
    return EnhancedEventRegistration(
      id: r['id']?.toString() ?? '',
      eventId: r['tournamentId']?.toString() ?? '',
      fighterId: (r['fighterUserId'] ?? r['fighterId'])?.toString() ?? '',
      status: _mapStatus(r['status']),
      weightClass: r['categoryName'] ?? r['divisionName'] ?? '',
      registeredAt: r['registeredAt'] != null ? DateTime.tryParse(r['registeredAt']) ?? DateTime.now() : DateTime.now(),
      coachId: null, // populate if api provides
      organizerId: t?['organizerId']?.toString(),
      rejectionReason: r['rejectionReason'],
    );
  }

  RegistrationStatus _mapStatus(String? status) {
    switch (status) {
      case 'PENDING': return RegistrationStatus.pending;
      case 'APPROVED': return RegistrationStatus.approvedByOrganizer;
      case 'REJECTED': return RegistrationStatus.rejected;
      case 'CANCELLED': return RegistrationStatus.cancelled;
      default: return RegistrationStatus.pending;
    }
  }

  // ── Fighter registrations ─────────────────────────────────────────────────

  Future<List<EnhancedEventRegistration>> getFighterRegistrations({
    required String fighterId,
  }) async {
    return _getAllRegistrationsAndFilter((r) => 
      (r['fighterUserId'] == fighterId || r['fighterId'] == fighterId));
  }

  // ── Coach registrations ───────────────────────────────────────────────────

  Future<List<EnhancedEventRegistration>> getCoachPendingRegistrations({
    required String coachId,
  }) async {
    // API doesn't specify coach registrations directly, filter by status pending for now
    // Actually, coach approval might not exist in the new API (just APPROVED/REJECTED).
    final regs = await _getAllRegistrationsAndFilter((r) => r['status'] == 'PENDING');
    return regs;
  }

  // ── Organizer registrations ───────────────────────────────────────────────

  Future<List<EnhancedEventRegistration>> getOrganizerPendingRegistrations({
    required String organizerId,
  }) async {
    return _getAllRegistrationsAndFilter((r) => r['status'] == 'PENDING');
  }

  Future<List<EnhancedEventRegistration>> _getAllRegistrationsAndFilter(bool Function(Map<String, dynamic>) filter) async {
    try {
      final tournamentsResp = await _api.get('/tournaments', queryParams: {'page': 0, 'size': 50});
      final List<dynamic> tournamentsData = (tournamentsResp['data']?['content'] ?? tournamentsResp['data'] ?? []);
      
      List<EnhancedEventRegistration> results = [];
      for (var t in tournamentsData) {
        if (t is! Map<String, dynamic>) continue;
        final String? tId = t['id'];
        if (tId == null) continue;
        try {
          final regResp = await _api.get('/tournaments/$tId/registrations');
          final List<dynamic> regs = regResp['data'] ?? [];
          for (var r in regs) {
            if (r is Map<String, dynamic> && filter(r)) {
               results.add(_mapToEnhanced(r, t));
            }
          }
        } catch (e) {
          // Ignore tournament fetch errors
        }
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<bool> registerForEvent(EnhancedEventRegistration registration) async {
    try {
      final data = {
        'fighterUserId': registration.fighterId,
        'tournamentCategoryId': registration.weightClass, // In the UI they might be selecting divisionId as weightClass
      };
      await _api.post('/tournaments/${registration.eventId}/registrations', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Approval / rejection ──────────────────────────────────────────────────

  Future<bool> approveByCoach({
    required String registrationId,
    required String coachId,
    String? notes,
  }) async {
    // Real API might only have one approve step
    try {
      await _api.patch('/tournaments/registrations/$registrationId/approve');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> approveByOrganizer({
    required String registrationId,
    required String organizerId,
    String? notes,
  }) async {
    try {
      await _api.patch('/tournaments/registrations/$registrationId/approve');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectRegistration({
    required String registrationId,
    required String rejectedBy,
    required String reason,
  }) async {
    try {
      await _api.patch('/tournaments/registrations/$registrationId/reject', data: {
        'reason': reason
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelRegistration(String registrationId) async {
    try {
      await _api.patch('/tournaments/registrations/$registrationId/cancel');
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Eligibility ───────────────────────────────────────────────────────────

  Future<EligibilityCheck> checkEligibility({
    required String fighterId,
    required String eventId,
  }) async {
    // Not explicitly in the API spec, return true for now
    return EligibilityCheck(isEligible: true);
  }

  // ── Event details ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getEventDetails(String eventId) async {
    try {
      final response = await _api.get('/tournaments/$eventId');
      return response['data'];
    } catch (e) {
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

extension RegistrationRepositoryExtension on RegistrationRepository {
  Future<bool> registerFighter(Map<String, dynamic> registrationData) async {
    try {
      final response = await _api.post('/auth/register-fighter', data: registrationData);
      print('Registration data: $registrationData');
      return response['success'] == true;
    } catch (e) {
      print('Error registering fighter: $e');
      rethrow;
    }
  }
}