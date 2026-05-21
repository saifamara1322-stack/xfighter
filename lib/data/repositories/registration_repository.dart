import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/enhanced_event_registration.dart';

class RegistrationRepository {
  final ApiClient _api = ApiClient();
  final List<EnhancedEventRegistration> _dummyRegistrations = [];

  // ── Fighter registrations ─────────────────────────────────────────────────

  Future<List<EnhancedEventRegistration>> getFighterRegistrations({
    required String fighterId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyRegistrations.where((r) => r.fighterId == fighterId).toList();
  }

  // ── Coach registrations ───────────────────────────────────────────────────

  Future<List<EnhancedEventRegistration>> getCoachPendingRegistrations({
    required String coachId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyRegistrations.where((r) => r.coachId == coachId).toList();
  }

  // ── Organizer registrations ───────────────────────────────────────────────

  Future<List<EnhancedEventRegistration>> getOrganizerPendingRegistrations({
    required String organizerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyRegistrations.where((r) => r.organizerId == organizerId).toList();
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<bool> registerForEvent(EnhancedEventRegistration registration) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _dummyRegistrations.add(registration);
    return true;
  }

  // ── Approval / rejection ──────────────────────────────────────────────────

  Future<bool> approveByCoach({
    required String registrationId,
    required String coachId,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _dummyRegistrations.indexWhere((r) => r.id == registrationId);
    if (index != -1) {
      final current = _dummyRegistrations[index];
      _dummyRegistrations[index] = EnhancedEventRegistration(
        id: current.id,
        eventId: current.eventId,
        fighterId: current.fighterId,
        status: RegistrationStatus.approvedByCoach,
        weightClass: current.weightClass,
        registeredAt: current.registeredAt,
        coachId: current.coachId,
        coachApprovedAt: DateTime.now(),
        notes: notes ?? current.notes,
      );
      return true;
    }
    return false;
  }

  Future<bool> approveByOrganizer({
    required String registrationId,
    required String organizerId,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _dummyRegistrations.indexWhere((r) => r.id == registrationId);
    if (index != -1) {
      final current = _dummyRegistrations[index];
      _dummyRegistrations[index] = EnhancedEventRegistration(
        id: current.id,
        eventId: current.eventId,
        fighterId: current.fighterId,
        status: RegistrationStatus.approvedByOrganizer,
        weightClass: current.weightClass,
        registeredAt: current.registeredAt,
        coachId: current.coachId,
        coachApprovedAt: current.coachApprovedAt,
        organizerId: organizerId,
        organizerApprovedAt: DateTime.now(),
        notes: notes ?? current.notes,
      );
      return true;
    }
    return false;
  }

  Future<bool> rejectRegistration({
    required String registrationId,
    required String rejectedBy,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _dummyRegistrations.indexWhere((r) => r.id == registrationId);
    if (index != -1) {
      final current = _dummyRegistrations[index];
      _dummyRegistrations[index] = EnhancedEventRegistration(
        id: current.id,
        eventId: current.eventId,
        fighterId: current.fighterId,
        status: RegistrationStatus.rejected,
        weightClass: current.weightClass,
        registeredAt: current.registeredAt,
        coachId: current.coachId,
        coachApprovedAt: current.coachApprovedAt,
        rejectionReason: reason,
        notes: current.notes,
      );
      return true;
    }
    return false;
  }

  Future<bool> cancelRegistration(String registrationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _dummyRegistrations.removeWhere((r) => r.id == registrationId);
    return true;
  }

  // ── Eligibility ───────────────────────────────────────────────────────────

  Future<EligibilityCheck> checkEligibility({
    required String fighterId,
    required String eventId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return EligibilityCheck(isEligible: true);
  }

  // ── Event details ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getEventDetails(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'id': eventId,
      'name': 'Dummy Event',
      'date': DateTime.now().add(const Duration(days: 10)).toIso8601String(),
    };
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
// Add this method to your RegistrationRepository
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