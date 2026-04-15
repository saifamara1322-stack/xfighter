import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/registration_repository.dart';
import '../models/event_model.dart';
import 'auth_controller.dart';
import 'fighter_controller.dart';

class RegistrationController extends GetxController {
  final RegistrationRepository _registrationRepository = RegistrationRepository();
  final AuthController _authController = Get.find<AuthController>();
  final FighterController _fighterController = Get.find<FighterController>(); // Changed from Get.put to Get.find
  
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
  
  // Cache for event details
  final Map<String, Event?> _eventCache = {};

  @override
  void onInit() {
    super.onInit();
    loadUserRegistrations();
  }
  
  // Helper method to safely show snackbars
  void _showSnackbar(String title, String message, {Color backgroundColor = Colors.green}) {
    // Ensure the widget tree is built before showing snackbar
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
  
  Future<void> loadUserRegistrations() async {
    final user = _authController.currentUser.value;
    if (user == null) return;
    
    try {
      isLoading.value = true;
      
      if (user.role == 'fighter') {
        final registrations = await _registrationRepository.getRegistrationsByFighter(user.id);
        fighterRegistrations.value = registrations.cast<EnhancedEventRegistration>();
        
        // Update counts
        pendingCount.value = getRegistrationsByStatus(RegistrationStatus.pending).length;
        approvedCount.value = getRegistrationsByStatus(RegistrationStatus.approvedByOrganizer).length;
      } else if (user.role == 'coach') {
        final registrations = await _registrationRepository.getPendingRegistrationsByCoach(user.id);
        pendingCoachRegistrations.value = registrations.cast<EnhancedEventRegistration>();
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des inscriptions: ${e.toString()}';
      print('Error loading registrations: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadEventRegistrations(String eventId) async {
    try {
      isLoading.value = true;
      eventRegistrations.value = (await _registrationRepository.getRegistrationsByEvent(eventId)).cast<EnhancedEventRegistration>();
    } catch (e) {
      print('Error loading event registrations: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> registerForEvent(String eventId, String weightClass) async {
    final user = _authController.currentUser.value;
    if (user == null || user.role != 'fighter') {
      _showSnackbar('Erreur', 'Seuls les combattants peuvent s\'inscrire', backgroundColor: Colors.red);
      return false;
    }
    
    try {
      isLoading.value = true;
      
      // Check eligibility
      final eligibility = await _registrationRepository.checkEligibility(user.id, eventId, weightClass);
      
      if (!eligibility.isEligible) {
        _showSnackbar(
          'Inscription impossible',
          eligibility.reasons.join('\n'),
          backgroundColor: Colors.red,
        );
        return false;
      }
      
      // Get coach ID if exists
      final fighter = _fighterController.currentFighter.value;
      final coachId = fighter?.coachId;
      
      final registrationData = {
        'eventId': eventId,
        'fighterId': user.id,
        'weightClass': weightClass,
        'coachId': coachId,
      };
      
      await _registrationRepository.createRegistration(registrationData);
      await loadUserRegistrations();
      
      _showSnackbar(
        'Succès',
        'Inscription envoyée! En attente d\'approbation du coach.',
        backgroundColor: Colors.green,
      );
      return true;
    } catch (e) {
      _showSnackbar('Erreur', 'Impossible de s\'inscrire: $e', backgroundColor: Colors.red);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> approveByCoach(String registrationId) async {
    final user = _authController.currentUser.value;
    if (user == null || user.role != 'coach') {
      _showSnackbar('Erreur', 'Action non autorisée', backgroundColor: Colors.red);
      return;
    }
    
    try {
      isLoading.value = true;
      await _registrationRepository.updateRegistrationStatus(
        registrationId, 
        RegistrationStatus.approvedByCoach as String,
        user.id
      );
      
      await loadUserRegistrations();
      
      _showSnackbar('Succès', 'Inscription approuvée par le coach', backgroundColor: Colors.green);
    } catch (e) {
      _showSnackbar('Erreur', 'Impossible d\'approuver: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> approveByOrganizer(String registrationId) async {
    final user = _authController.currentUser.value;
    if (user == null || (user.role != 'organizer' && user.role != 'admin')) {
      _showSnackbar('Erreur', 'Action non autorisée', backgroundColor: Colors.red);
      return;
    }
    
    try {
      isLoading.value = true;
      await _registrationRepository.updateRegistrationStatus(
        registrationId, 
        RegistrationStatus.approvedByOrganizer as String,
        user.id
      );
      
      // Reload to update counts
      await loadUserRegistrations();
      
      _showSnackbar('Succès', 'Inscription confirmée!', backgroundColor: Colors.green);
    } catch (e) {
      _showSnackbar('Erreur', 'Impossible de confirmer: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> rejectRegistration(String registrationId, String reason) async {
    final user = _authController.currentUser.value;
    if (user == null) return;
    
    try {
      isLoading.value = true;
      await _registrationRepository.updateRegistrationStatus(
        registrationId, 
        RegistrationStatus.rejected as String,
        user.id,
        rejectionReason: reason
      );
      
      await loadUserRegistrations();
      
      _showSnackbar('Succès', 'Inscription rejetée', backgroundColor: Colors.green);
    } catch (e) {
      _showSnackbar('Erreur', 'Impossible de rejeter: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> checkEligibility(String eventId, String weightClass) async {
    final user = _authController.currentUser.value;
    if (user == null) return;
    
    try {
      isCheckingEligibility.value = true;
      eligibilityResult.value = await _registrationRepository.checkEligibility(user.id, eventId, weightClass);
    } catch (e) {
      print('Error checking eligibility: $e');
    } finally {
      isCheckingEligibility.value = false;
    }
  }
  
  Future<Event?> getEventDetails(String eventId) async {
    // Check cache first
    if (_eventCache.containsKey(eventId)) {
      return _eventCache[eventId];
    }
    
    try {
      // Fetch event using existing repository method
      final event = await _registrationRepository.getEventById(eventId);
      _eventCache[eventId] = event;
      return event;
    } catch (e) {
      debugPrint('Error loading event $eventId: $e');
      return null;
    }
  }
  
  Future<bool> cancelRegistration(String registrationId) async {
    try {
      isLoading.value = true;
      
      // Call existing repository method to cancel/delete registration
      await _registrationRepository.deleteRegistration(registrationId);
      
      // Reload registrations
      await loadUserRegistrations();
      
      _showSnackbar(
        'Succès',
        'Inscription annulée avec succès',
        backgroundColor: Colors.green,
      );
      
      return true;
    } catch (e) {
      _showSnackbar(
        'Erreur',
        'Impossible d\'annuler l\'inscription: $e',
        backgroundColor: Colors.red,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  List<EnhancedEventRegistration> getRegistrationsByStatus(RegistrationStatus status) {
    return fighterRegistrations.where((r) => r.status == status).toList();
  }
  
  int get approvedByCoachCount => getRegistrationsByStatus(RegistrationStatus.approvedByCoach).length;

  void loadFighterRegistrations() {}
}