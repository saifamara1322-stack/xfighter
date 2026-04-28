import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/registration_repository.dart';
import '../../../data/models/event_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../fighter/controllers/fighter_controller.dart';

class RegistrationController extends GetxController {
  final RegistrationRepository _registrationRepository = RegistrationRepository();
  final AuthController _authController = Get.find<AuthController>();
  final FighterController _fighterController = Get.find<FighterController>();
  
  var fighterRegistrations = <EnhancedEventRegistration>[].obs;
  var pendingCoachRegistrations = <EnhancedEventRegistration>[].obs;
  var eventRegistrations = <EnhancedEventRegistration>[].obs;
  var isLoading = false.obs;
  var isCheckingEligibility = false.obs;
  var eligibilityResult = Rx<EligibilityCheck?>(null);
  
  final pendingCount = 0.obs;
  final approvedCount = 0.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  final Map<String, Event?> _eventCache = {};

  @override
  void onInit() {
    super.onInit();
    loadUserRegistrations();
  }
  
  // Load all registrations for the current user
  Future<void> loadUserRegistrations() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      final currentUser = _authController.currentUser.value;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }
      
      // Load registrations based on user role
      if (currentUser.role == UserRole.fighter) {
        await loadFighterRegistrations();
      } else if (currentUser.role == UserRole.coach) {
        await loadCoachRegistrations();
      } else if (currentUser.role == UserRole.organizer) {
        await loadOrganizerRegistrations();
      }
      
      _updateCounts();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load registrations: ${e.toString()}';
      _showSnackbar('Error', errorMessage.value, backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load fighter registrations
  Future<void> loadFighterRegistrations() async {
    try {
      final currentUser = _authController.currentUser.value;
      if (currentUser == null) return;
      
      final registrations = await _registrationRepository.getFighterRegistrations(
        fighterId: currentUser.id,
      );
      fighterRegistrations.value = registrations;
      
      // Cache events
      for (var registration in registrations) {
        if (registration.event != null) {
          _eventCache[registration.eventId] = registration.event;
        }
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to load fighter registrations: ${e.toString()}', backgroundColor: Colors.red);
    }
  }
  
  // Load coach registrations
  Future<void> loadCoachRegistrations() async {
    try {
      final currentUser = _authController.currentUser.value;
      if (currentUser == null) return;
      
      final registrations = await _registrationRepository.getCoachRegistrations(
        coachId: currentUser.id,
      );
      pendingCoachRegistrations.value = registrations;
      
      // Cache events
      for (var registration in registrations) {
        if (registration.event != null) {
          _eventCache[registration.eventId] = registration.event;
        }
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to load coach registrations: ${e.toString()}', backgroundColor: Colors.red);
    }
  }
  
  // Load organizer registrations (all registrations for events they organize)
  Future<void> loadOrganizerRegistrations() async {
    try {
      final currentUser = _authController.currentUser.value;
      if (currentUser == null) return;
      
      final registrations = await _registrationRepository.getEventRegistrations(
        organizerId: currentUser.id,
      );
      eventRegistrations.value = registrations;
      
      // Cache events
      for (var registration in registrations) {
        if (registration.event != null) {
          _eventCache[registration.eventId] = registration.event;
        }
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to load event registrations: ${e.toString()}', backgroundColor: Colors.red);
    }
  }
  
  // Register for an event
  Future<bool> registerForEvent(Event event, {String? teamName, List<String>? teamMembers}) async {
    try {
      isLoading.value = true;
      
      final currentUser = _authController.currentUser.value;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }
      
      // Check eligibility before registering
      final isEligible = await checkEligibility(event.id);
      if (!isEligible) {
        _showSnackbar('Not Eligible', 'You are not eligible for this event', backgroundColor: Colors.orange);
        return false;
      }
      
      final registration = EnhancedEventRegistration(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        eventId: event.id,
        userId: currentUser.id,
        user: currentUser,
        event: event,
        status: 'pending',
        registeredAt: DateTime.now(),
        updatedAt: DateTime.now(),
        teamName: teamName,
        teamMembers: teamMembers,
      );
      
      final result = await _registrationRepository.registerForEvent(registration);
      
      if (result) {
        // Refresh registrations based on role
        if (currentUser.role == UserRole.fighter) {
          await loadFighterRegistrations();
        } else if (currentUser.role == UserRole.coach) {
          await loadCoachRegistrations();
        }
        
        _updateCounts();
        _showSnackbar('Success', 'Successfully registered for event', backgroundColor: Colors.green);
        return true;
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to register: ${e.toString()}', backgroundColor: Colors.red);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Check fighter eligibility for an event
  Future<bool> checkEligibility(String eventId) async {
    try {
      isCheckingEligibility.value = true;
      
      final currentUser = _authController.currentUser.value;
      if (currentUser == null || currentUser.role != UserRole.fighter) {
        return false;
      }
      
      final fighterProfile = _fighterController.fighterProfile.value;
      if (fighterProfile == null) {
        _showSnackbar('Profile Required', 'Please complete your fighter profile first', backgroundColor: Colors.orange);
        return false;
      }
      
      final result = await _registrationRepository.checkEligibility(
        fighterId: currentUser.id,
        eventId: eventId,
      );
      
      eligibilityResult.value = result;
      
      if (!result.isEligible) {
        _showSnackbar('Not Eligible', result.reason ?? 'You are not eligible for this event', backgroundColor: Colors.orange);
      }
      
      return result.isEligible;
    } catch (e) {
      _showSnackbar('Error', 'Failed to check eligibility: ${e.toString()}', backgroundColor: Colors.red);
      return false;
    } finally {
      isCheckingEligibility.value = false;
    }
  }
  
  // Update registration status (for organizers/admins)
  Future<void> updateRegistrationStatus(String registrationId, String newStatus) async {
    try {
      isLoading.value = true;
      
      await _registrationRepository.updateRegistrationStatus(registrationId, newStatus);
      
      // Update local lists
      await _updateLocalRegistrationStatus(registrationId, newStatus);
      
      _updateCounts();
      _showSnackbar('Success', 'Registration ${_getStatusMessage(newStatus)}', backgroundColor: Colors.green);
    } catch (e) {
      _showSnackbar('Error', 'Failed to update status: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  // Cancel registration
  Future<bool> cancelRegistration(String registrationId) async {
    try {
      isLoading.value = true;
      
      final result = await _registrationRepository.cancelRegistration(registrationId);
      
      if (result) {
        // Remove from local lists
        fighterRegistrations.removeWhere((reg) => reg.id == registrationId);
        pendingCoachRegistrations.removeWhere((reg) => reg.id == registrationId);
        eventRegistrations.removeWhere((reg) => reg.id == registrationId);
        
        _updateCounts();
        _showSnackbar('Success', 'Registration cancelled successfully', backgroundColor: Colors.green);
        return true;
      } else {
        throw Exception('Failed to cancel registration');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to cancel: ${e.toString()}', backgroundColor: Colors.red);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Get registrations for a specific event (organizer view)
  Future<List<EnhancedEventRegistration>> getEventRegistrations(String eventId) async {
    try {
      final registrations = await _registrationRepository.getEventRegistrationsByEventId(eventId);
      return registrations;
    } catch (e) {
      _showSnackbar('Error', 'Failed to load event registrations: ${e.toString()}', backgroundColor: Colors.red);
      return [];
    }
  }
  
  // Update counts for dashboard
  void _updateCounts() {
    pendingCount.value = fighterRegistrations.where((r) => r.status == 'pending').length +
                         pendingCoachRegistrations.where((r) => r.status == 'pending').length;
    
    approvedCount.value = fighterRegistrations.where((r) => r.status == 'approved').length +
                          pendingCoachRegistrations.where((r) => r.status == 'approved').length;
  }
  
  // Update local registration status
  Future<void> _updateLocalRegistrationStatus(String registrationId, String newStatus) async {
    // Update in fighterRegistrations
    final fighterIndex = fighterRegistrations.indexWhere((r) => r.id == registrationId);
    if (fighterIndex != -1) {
      fighterRegistrations[fighterIndex].status = newStatus;
      fighterRegistrations.refresh();
    }
    
    // Update in pendingCoachRegistrations
    final coachIndex = pendingCoachRegistrations.indexWhere((r) => r.id == registrationId);
    if (coachIndex != -1) {
      pendingCoachRegistrations[coachIndex].status = newStatus;
      pendingCoachRegistrations.refresh();
    }
    
    // Update in eventRegistrations
    final eventIndex = eventRegistrations.indexWhere((r) => r.id == registrationId);
    if (eventIndex != -1) {
      eventRegistrations[eventIndex].status = newStatus;
      eventRegistrations.refresh();
    }
  }
  
  // Get status message for snackbar
  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'approved';
      case 'rejected':
        return 'rejected';
      case 'cancelled':
        return 'cancelled';
      default:
        return 'updated';
    }
  }
  
  // Clear error state
  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }
  
  // Refresh all data
  Future<void> refreshData() async {
    await loadUserRegistrations();
    if (_authController.currentUser.value?.role == UserRole.fighter) {
      await _fighterController.refreshProfile();
    }
  }
  
  // Get event from cache or fetch
  Future<Event?> getEvent(String eventId) async {
    if (_eventCache.containsKey(eventId)) {
      return _eventCache[eventId];
    }
    
    try {
      final event = await _registrationRepository.getEventDetails(eventId);
      _eventCache[eventId] = event;
      return event;
    } catch (e) {
      return null;
    }
  }
  
  // Export registrations to CSV (organizer only)
  Future<String?> exportRegistrationsToCsv(String eventId) async {
    try {
      isLoading.value = true;
      final csvUrl = await _registrationRepository.exportRegistrationsToCsv(eventId);
      _showSnackbar('Success', 'Export completed', backgroundColor: Colors.green);
      return csvUrl;
    } catch (e) {
      _showSnackbar('Error', 'Failed to export: ${e.toString()}', backgroundColor: Colors.red);
      return null;
    } finally {
      isLoading.value = false;
    }
  }
  
  void _showSnackbar(String title, String message, {Color backgroundColor = Colors.green}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: backgroundColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
        );
      }
    });
  }
}

// Eligibility Check Model
class EligibilityCheck {
  final bool isEligible;
  final String? reason;
  final Map<String, dynamic>? details;
  
  EligibilityCheck({
    required this.isEligible,
    this.reason,
    this.details,
  });
  
  factory EligibilityCheck.fromJson(Map<String, dynamic> json) {
    return EligibilityCheck(
      isEligible: json['isEligible'] ?? false,
      reason: json['reason'],
      details: json['details'],
    );
  }
}