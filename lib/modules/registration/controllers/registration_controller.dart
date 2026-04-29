import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/registration_repository.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../fighter/controllers/fighter_controller.dart';

class RegistrationController extends GetxController {
  final RegistrationRepository _registrationRepository = RegistrationRepository();
  final AuthController _authController = Get.find<AuthController>();
  final FighterController _fighterController = Get.find<FighterController>();
  
  // Registration lists
  var fighterRegistrations = <EnhancedEventRegistration>[].obs;
  var coachRegistrations = <EnhancedEventRegistration>[].obs;
  var pendingCoachRegistrations = <EnhancedEventRegistration>[].obs;
  var eventRegistrations = <EnhancedEventRegistration>[].obs;
  
  // UI states
  var isLoading = false.obs;
  var isCheckingEligibility = false.obs;
  var eligibilityResult = Rx<EligibilityCheck?>(null);
  
  // Counters
  final pendingCount = 0.obs;
  final coachApprovedCount = 0.obs;
  final organizerApprovedCount = 0.obs;
  final rejectedCount = 0.obs;
  
  // Error handling
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  // Cache
  final Map<String, Map<String, dynamic>?> _eventCache = {};

  @override
  void onInit() {
    super.onInit();
    loadUserRegistrations();
  }
  
  // Load all registrations for the current user based on role
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
      switch (currentUser.role) {
        case UserRole.FIGHTER:
          await loadFighterRegistrations();
          break;
        case UserRole.COACH:
          await loadCoachRegistrations();
          break;
        case UserRole.ORGANIZER:
        case UserRole.ADMIN:
          await loadOrganizerRegistrations();
          break;
        default:
          break;
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
  
  // Load fighter registrations (for fighters)
  Future<void> loadFighterRegistrations() async {
    try {
      final currentUser = _authController.currentUser.value;
      if (currentUser == null) return;
      
      final registrations = await _registrationRepository.getFighterRegistrations(
        fighterId: currentUser.id,
      );
      fighterRegistrations.value = registrations;
      
      for (var registration in registrations) {
        if (registration.event != null) {
          _eventCache[registration.eventId] = registration.event?.toJson();
        }
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to load fighter registrations: ${e.toString()}', backgroundColor: Colors.red);
    }
  }
  
  // Load coach registrations (for coaches - registrations they need to approve)
  Future<void> loadCoachRegistrations() async {
    try {
      final currentUser = _authController.currentUser.value;
      if (currentUser == null) return;
      
      final registrations = await _registrationRepository.getCoachPendingRegistrations(
        coachId: currentUser.id,
      );
      pendingCoachRegistrations.value = registrations;
      coachRegistrations.value = registrations;
      
      for (var registration in registrations) {
        if (registration.event != null) {
          _eventCache[registration.eventId] = registration.event?.toJson();
        }
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to load coach registrations: ${e.toString()}', backgroundColor: Colors.red);
    }
  }
  
  // Fetch coach registrations (alias for loadCoachRegistrations)
  Future<void> fetchCoachRegistrations() async {
    await loadCoachRegistrations();
  }
  
  // Load organizer registrations (for organizers - registrations needing final approval)
  Future<void> loadOrganizerRegistrations() async {
    try {
      final currentUser = _authController.currentUser.value;
      if (currentUser == null) return;
      
      final registrations = await _registrationRepository.getOrganizerPendingRegistrations(
        organizerId: currentUser.id,
      );
      eventRegistrations.value = registrations;
      
      for (var registration in registrations) {
        if (registration.event != null) {
          _eventCache[registration.eventId] = registration.event?.toJson();
        }
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to load organizer registrations: ${e.toString()}', backgroundColor: Colors.red);
    }
  }
  
  // Update registration status
  Future<void> updateRegistrationStatus(String registrationId, String status) async {
    try {
      isLoading.value = true;
      
      final currentUser = _authController.currentUser.value;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }
      
      RegistrationStatus newStatus;
      switch (status.toLowerCase()) {
        case 'approved':
          newStatus = RegistrationStatus.approvedByCoach;
          break;
        case 'rejected':
          newStatus = RegistrationStatus.rejected;
          break;
        case 'cancelled':
          newStatus = RegistrationStatus.cancelled;
          break;
        default:
          throw Exception('Invalid status: $status');
      }
      
      bool result;
      if (newStatus == RegistrationStatus.approvedByCoach) {
        result = await _registrationRepository.approveByCoach(
          registrationId: registrationId,
          coachId: currentUser.id,
        );
      } else if (newStatus == RegistrationStatus.rejected) {
        result = await _registrationRepository.rejectRegistration(
          registrationId: registrationId,
          rejectedBy: currentUser.id,
          reason: 'Rejected by coach',
        );
      } else {
        result = await _registrationRepository.cancelRegistration(registrationId);
      }
      
      if (result) {
        await _updateLocalRegistrationStatus(registrationId, newStatus);
        await loadCoachRegistrations();
        _updateCounts();
        
        String message = status == 'approved' ? 'Registration approved successfully' :
                        status == 'rejected' ? 'Registration rejected' :
                        'Registration cancelled';
        
        _showSnackbar('Success', message, backgroundColor: Colors.green);
      } else {
        throw Exception('Failed to update registration status');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to update status: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  // Register fighter for an event
  Future<bool> registerForEvent({
    required String eventId,
    required String weightClass,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      
      final currentUser = _authController.currentUser.value;
      if (currentUser == null || currentUser.role != UserRole.FIGHTER) {
        throw Exception('Only fighters can register for events');
      }
      
      // Check eligibility
      final isEligible = await checkEligibility(eventId);
      if (!isEligible) {
        return false;
      }
      
      // Get fighter's current profile
      final fighterProfile = _fighterController.currentFighter.value;
      final coachId = fighterProfile?.coach?.id;
      
      final registration = EnhancedEventRegistration(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        eventId: eventId,
        fighterId: currentUser.id,
        status: RegistrationStatus.pending,
        weightClass: weightClass,
        registeredAt: DateTime.now(),
        coachId: coachId,
        notes: notes,
      );
      
      final result = await _registrationRepository.registerForEvent(registration);
      
      if (result) {
        await loadFighterRegistrations();
        _updateCounts();
        _showSnackbar('Success', 'Registration submitted successfully', backgroundColor: Colors.green);
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
  
  // Coach approves a fighter registration
  Future<bool> approveByCoach(String registrationId, {String? notes}) async {
    try {
      isLoading.value = true;
      
      final currentUser = _authController.currentUser.value;
      if (currentUser == null || currentUser.role != UserRole.COACH) {
        throw Exception('Only coaches can perform this action');
      }
      
      final result = await _registrationRepository.approveByCoach(
        registrationId: registrationId,
        coachId: currentUser.id,
        notes: notes,
      );
      
      if (result) {
        pendingCoachRegistrations.removeWhere((reg) => reg.id == registrationId);
        coachRegistrations.removeWhere((reg) => reg.id == registrationId);
        
        _updateCounts();
        _showSnackbar('Success', 'Registration approved', backgroundColor: Colors.green);
        return true;
      } else {
        throw Exception('Approval failed');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to approve: ${e.toString()}', backgroundColor: Colors.red);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Organizer approves a fighter registration (final approval)
  Future<bool> approveByOrganizer(String registrationId, {String? notes}) async {
    try {
      isLoading.value = true;
      
      final currentUser = _authController.currentUser.value;
      if (currentUser == null || (currentUser.role != UserRole.ORGANIZER && currentUser.role != UserRole.ADMIN)) {
        throw Exception('Only organizers can perform this action');
      }
      
      final result = await _registrationRepository.approveByOrganizer(
        registrationId: registrationId,
        organizerId: currentUser.id,
        notes: notes,
      );
      
      if (result) {
        await _updateLocalRegistrationStatus(registrationId, RegistrationStatus.approvedByOrganizer);
        
        _updateCounts();
        _showSnackbar('Success', 'Registration fully approved', backgroundColor: Colors.green);
        return true;
      } else {
        throw Exception('Approval failed');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to approve: ${e.toString()}', backgroundColor: Colors.red);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Reject a registration
  Future<bool> rejectRegistration(String registrationId, String reason) async {
    try {
      isLoading.value = true;
      
      final currentUser = _authController.currentUser.value;
      final result = await _registrationRepository.rejectRegistration(
        registrationId: registrationId,
        rejectedBy: currentUser!.id,
        reason: reason,
      );
      
      if (result) {
        await _updateLocalRegistrationStatus(registrationId, RegistrationStatus.rejected);
        
        _updateCounts();
        _showSnackbar('Info', 'Registration rejected', backgroundColor: Colors.orange);
        return true;
      } else {
        throw Exception('Rejection failed');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to reject: ${e.toString()}', backgroundColor: Colors.red);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Cancel registration (fighter self-cancel)
  Future<bool> cancelRegistration(String registrationId) async {
    try {
      isLoading.value = true;
      
      final result = await _registrationRepository.cancelRegistration(registrationId);
      
      if (result) {
        fighterRegistrations.removeWhere((reg) => reg.id == registrationId);
        
        _updateCounts();
        _showSnackbar('Success', 'Registration cancelled', backgroundColor: Colors.green);
        return true;
      } else {
        throw Exception('Cancellation failed');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to cancel: ${e.toString()}', backgroundColor: Colors.red);
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
      if (currentUser == null || currentUser.role != UserRole.FIGHTER) {
        return false;
      }
      
      final fighterProfile = _fighterController.currentFighter.value;
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
  
  // Get status display text and color
  Map<String, dynamic> getRegistrationStatusInfo(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.pending:
        return {
          'text': 'Pending Coach Approval',
          'color': Colors.orange,
          'icon': Icons.pending_actions,
        };
      case RegistrationStatus.approvedByCoach:
        return {
          'text': 'Pending Organizer Approval',
          'color': Colors.blue,
          'icon': Icons.verified,
        };
      case RegistrationStatus.approvedByOrganizer:
        return {
          'text': 'Approved',
          'color': Colors.green,
          'icon': Icons.check_circle,
        };
      case RegistrationStatus.rejected:
        return {
          'text': 'Rejected',
          'color': Colors.red,
          'icon': Icons.cancel,
        };
      case RegistrationStatus.cancelled:
        return {
          'text': 'Cancelled',
          'color': Colors.grey,
          'icon': Icons.remove_circle,
        };
    }
  }
  
  // Update local registration status
  Future<void> _updateLocalRegistrationStatus(String registrationId, RegistrationStatus newStatus) async {
    // Update in fighterRegistrations
    final fighterIndex = fighterRegistrations.indexWhere((r) => r.id == registrationId);
    if (fighterIndex != -1) {
      final updatedReg = EnhancedEventRegistration(
        id: fighterRegistrations[fighterIndex].id,
        eventId: fighterRegistrations[fighterIndex].eventId,
        fighterId: fighterRegistrations[fighterIndex].fighterId,
        status: newStatus,
        weightClass: fighterRegistrations[fighterIndex].weightClass,
        registeredAt: fighterRegistrations[fighterIndex].registeredAt,
        coachId: fighterRegistrations[fighterIndex].coachId,
        coachApprovedAt: newStatus == RegistrationStatus.approvedByCoach ? DateTime.now() : fighterRegistrations[fighterIndex].coachApprovedAt,
        organizerId: fighterRegistrations[fighterIndex].organizerId,
        organizerApprovedAt: newStatus == RegistrationStatus.approvedByOrganizer ? DateTime.now() : fighterRegistrations[fighterIndex].organizerApprovedAt,
        rejectionReason: newStatus == RegistrationStatus.rejected ? fighterRegistrations[fighterIndex].rejectionReason : null,
        notes: fighterRegistrations[fighterIndex].notes,
      );
      fighterRegistrations[fighterIndex] = updatedReg;
      fighterRegistrations.refresh();
    }
    
    // Update in coachRegistrations
    final coachIndex = coachRegistrations.indexWhere((r) => r.id == registrationId);
    if (coachIndex != -1) {
      final updatedReg = EnhancedEventRegistration(
        id: coachRegistrations[coachIndex].id,
        eventId: coachRegistrations[coachIndex].eventId,
        fighterId: coachRegistrations[coachIndex].fighterId,
        status: newStatus,
        weightClass: coachRegistrations[coachIndex].weightClass,
        registeredAt: coachRegistrations[coachIndex].registeredAt,
        coachId: coachRegistrations[coachIndex].coachId,
        coachApprovedAt: newStatus == RegistrationStatus.approvedByCoach ? DateTime.now() : coachRegistrations[coachIndex].coachApprovedAt,
        organizerId: coachRegistrations[coachIndex].organizerId,
        organizerApprovedAt: newStatus == RegistrationStatus.approvedByOrganizer ? DateTime.now() : coachRegistrations[coachIndex].organizerApprovedAt,
        rejectionReason: newStatus == RegistrationStatus.rejected ? coachRegistrations[coachIndex].rejectionReason : null,
        notes: coachRegistrations[coachIndex].notes,
      );
      coachRegistrations[coachIndex] = updatedReg;
      coachRegistrations.refresh();
    }
    
    // Update in eventRegistrations (organizer view)
    final eventIndex = eventRegistrations.indexWhere((r) => r.id == registrationId);
    if (eventIndex != -1) {
      final updatedReg = EnhancedEventRegistration(
        id: eventRegistrations[eventIndex].id,
        eventId: eventRegistrations[eventIndex].eventId,
        fighterId: eventRegistrations[eventIndex].fighterId,
        status: newStatus,
        weightClass: eventRegistrations[eventIndex].weightClass,
        registeredAt: eventRegistrations[eventIndex].registeredAt,
        coachId: eventRegistrations[eventIndex].coachId,
        coachApprovedAt: eventRegistrations[eventIndex].coachApprovedAt,
        organizerId: newStatus == RegistrationStatus.approvedByOrganizer ? _authController.currentUser.value?.id : eventRegistrations[eventIndex].organizerId,
        organizerApprovedAt: newStatus == RegistrationStatus.approvedByOrganizer ? DateTime.now() : eventRegistrations[eventIndex].organizerApprovedAt,
        rejectionReason: newStatus == RegistrationStatus.rejected ? eventRegistrations[eventIndex].rejectionReason : null,
        notes: eventRegistrations[eventIndex].notes,
      );
      eventRegistrations[eventIndex] = updatedReg;
      eventRegistrations.refresh();
    }
  }
  
  // Update counts for dashboard
  void _updateCounts() {
    pendingCount.value = fighterRegistrations.where((r) => r.status == RegistrationStatus.pending).length +
                         pendingCoachRegistrations.where((r) => r.status == RegistrationStatus.pending).length;
    
    coachApprovedCount.value = fighterRegistrations.where((r) => r.status == RegistrationStatus.approvedByCoach).length +
                               pendingCoachRegistrations.where((r) => r.status == RegistrationStatus.approvedByCoach).length;
    
    organizerApprovedCount.value = fighterRegistrations.where((r) => r.status == RegistrationStatus.approvedByOrganizer).length +
                                   pendingCoachRegistrations.where((r) => r.status == RegistrationStatus.approvedByOrganizer).length;
    
    rejectedCount.value = fighterRegistrations.where((r) => r.status == RegistrationStatus.rejected).length +
                          pendingCoachRegistrations.where((r) => r.status == RegistrationStatus.rejected).length;
  }
  
  // Get registrations by status
  List<EnhancedEventRegistration> getRegistrationsByStatus(RegistrationStatus status) {
    return fighterRegistrations.where((r) => r.status == status).toList();
  }
  
  // Check if registration is pending approval
  bool isRegistrationPending(EnhancedEventRegistration registration) {
    return registration.status == RegistrationStatus.pending;
  }
  
  // Check if registration needs organizer approval
  bool needsOrganizerApproval(EnhancedEventRegistration registration) {
    return registration.status == RegistrationStatus.approvedByCoach;
  }
  
  // Check if registration is fully approved
  bool isFullyApproved(EnhancedEventRegistration registration) {
    return registration.status == RegistrationStatus.approvedByOrganizer;
  }
  
  // Clear error state
  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }
  
  // Refresh all data
  Future<void> refreshData() async {
    await loadUserRegistrations();
    if (_authController.currentUser.value?.role == UserRole.FIGHTER) {
      final userId = _authController.currentUser.value?.id;
      if (userId != null) {
        await _fighterController.loadFighterProfile(userId);
      }
    }
  }
  
  // Get event from cache or fetch
  Future<Map<String, dynamic>?> getEvent(String eventId) async {
    if (_eventCache.containsKey(eventId)) {
      return _eventCache[eventId];
    }
    
    try {
      final eventData = await _registrationRepository.getEventDetails(eventId);
      _eventCache[eventId] = eventData;
      return eventData;
    } catch (e) {
      return null;
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

// EligibilityCheck is defined in registration_repository.dart