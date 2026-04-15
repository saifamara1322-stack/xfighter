import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/event_repository.dart';
import '../models/event_model.dart';
import 'auth_controller.dart';

class EventController extends GetxController {
  final EventRepository _eventRepository = EventRepository();
  final AuthController _authController = Get.find<AuthController>();
  
  var events = <Event>[].obs;
  var upcomingEvents = <Event>[].obs;
  var organizerEvents = <Event>[].obs;
  var selectedEvent = Rx<Event?>(null);
  var eventRegistrations = <EventRegistration>[].obs;
  var isLoading = false.obs;
  var isCreating = false.obs;
  
  // Form controllers for event creation
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final cityController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final ticketPriceController = TextEditingController();
  final maxFightersController = TextEditingController();
  var selectedDisciplines = <String>[].obs;
  var selectedWeightClasses = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }
  
  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    cityController.dispose();
    dateController.dispose();
    timeController.dispose();
    ticketPriceController.dispose();
    maxFightersController.dispose();
    super.onClose();
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
  
  Future<void> loadEvents() async {
    try {
      isLoading.value = true;
      events.value = await _eventRepository.getAllEvents();
      upcomingEvents.value = events.where((e) => 
        e.status == EventStatus.upcoming || e.status == EventStatus.approved
      ).toList();
      
      final user = _authController.currentUser.value;
      if (user != null && (user.role.name == 'organizer' || user.role.name == 'admin')) {
        organizerEvents.value = await _eventRepository.getEventsByOrganizer(user.id);
      }
    } catch (e) {
      _showSnackbar('Erreur', 'Impossible de charger les événements: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> selectEvent(String eventId) async {
    try {
      isLoading.value = true;
      selectedEvent.value = await _eventRepository.getEventById(eventId);
      if (selectedEvent.value != null) {
        await loadEventRegistrations(eventId);
      }
    } catch (e) {
      _showSnackbar('Erreur', 'Impossible de charger l\'événement: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadEventRegistrations(String eventId) async {
    try {
      eventRegistrations.value = await _eventRepository.getEventRegistrations(eventId);
    } catch (e) {
      // Use a logging framework instead of print
      debugPrint('Error loading registrations: $e');
    }
  }
  
  Future<void> createEvent() async {
    if (!_validateForm()) return;
    
    final user = _authController.currentUser.value;
    if (user == null) return;
    
    try {
      isCreating.value = true;
      
      // Combine date and time
      final dateTime = DateTime.parse('${dateController.text}T${timeController.text}:00');
      
      final eventData = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'organizerId': user.id,
        'date': dateTime.toIso8601String(),
        'location': locationController.text.trim(),
        'city': cityController.text.trim(),
        'disciplines': selectedDisciplines,
        'weightClasses': selectedWeightClasses,
        'ticketPrice': double.parse(ticketPriceController.text),
        'maxFighters': int.parse(maxFightersController.text),
      };
      
      await _eventRepository.createEvent(eventData);
      
      _clearForm();
      await loadEvents();
      
      Get.back();
      _showSnackbar(
        'Succès',
        'Événement créé! En attente d\'approbation.',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      _showSnackbar('Erreur', 'Impossible de créer l\'événement: $e', backgroundColor: Colors.red);
    } finally {
      isCreating.value = false;
    }
  }
  
  Future<void> updateEventStatus(String eventId, String status) async {
    if (!_authController.isAdmin()) {
      _showSnackbar('Erreur', 'Action non autorisée', backgroundColor: Colors.red);
      return;
    }
    
    try {
      isLoading.value = true;
      await _eventRepository.updateEventStatus(eventId, status, _authController.currentUser.value?.id);
      await loadEvents();
      
      _showSnackbar('Succès', 'Statut de l\'événement mis à jour', backgroundColor: Colors.green);
    } catch (e) {
      _showSnackbar('Erreur', 'Impossible de mettre à jour: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> registerForEvent(String eventId, String weightClass) async {
    final user = _authController.currentUser.value;
    if (user == null || user.role.name != 'fighter') {
      _showSnackbar('Erreur', 'Seuls les combattants peuvent s\'inscrire', backgroundColor: Colors.red);
      return;
    }
    
    try {
      isLoading.value = true;
      
      final registrationData = {
        'eventId': eventId,
        'fighterId': user.id,
        'weightClass': weightClass,
      };
      
      await _eventRepository.registerFighter(registrationData);
      
      _showSnackbar(
        'Succès',
        'Inscription envoyée! En attente d\'approbation.',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      _showSnackbar('Erreur', 'Impossible de s\'inscrire: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer le nom de l\'événement', backgroundColor: Colors.red);
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer une description', backgroundColor: Colors.red);
      return false;
    }
    if (locationController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer le lieu', backgroundColor: Colors.red);
      return false;
    }
    if (cityController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer la ville', backgroundColor: Colors.red);
      return false;
    }
    if (dateController.text.isEmpty) {
      _showSnackbar('Erreur', 'Veuillez choisir une date', backgroundColor: Colors.red);
      return false;
    }
    if (timeController.text.isEmpty) {
      _showSnackbar('Erreur', 'Veuillez choisir une heure', backgroundColor: Colors.red);
      return false;
    }
    if (selectedDisciplines.isEmpty) {
      _showSnackbar('Erreur', 'Veuillez sélectionner au moins une discipline', backgroundColor: Colors.red);
      return false;
    }
    if (selectedWeightClasses.isEmpty) {
      _showSnackbar('Erreur', 'Veuillez sélectionner au moins une catégorie', backgroundColor: Colors.red);
      return false;
    }
    if (ticketPriceController.text.isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer le prix du billet', backgroundColor: Colors.red);
      return false;
    }
    return true;
  }
  
  void _clearForm() {
    nameController.clear();
    descriptionController.clear();
    locationController.clear();
    cityController.clear();
    dateController.clear();
    timeController.clear();
    ticketPriceController.clear();
    maxFightersController.clear();
    selectedDisciplines.clear();
    selectedWeightClasses.clear();
  }
  
  void toggleDiscipline(String discipline) {
    if (selectedDisciplines.contains(discipline)) {
      selectedDisciplines.remove(discipline);
    } else {
      selectedDisciplines.add(discipline);
    }
  }
  
  void toggleWeightClass(String weightClass) {
    if (selectedWeightClasses.contains(weightClass)) {
      selectedWeightClasses.remove(weightClass);
    } else {
      selectedWeightClasses.add(weightClass);
    }
  }
  
  List<Event> get pendingEvents {
    return events.where((e) => e.status == EventStatus.pending).toList();
  }
  
  List<Event> get approvedEvents {
    return events.where((e) => e.status == EventStatus.approved || e.status == EventStatus.upcoming).toList();
  }
}