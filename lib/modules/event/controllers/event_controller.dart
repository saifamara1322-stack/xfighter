import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/models/event_model.dart';
import '../../auth/controllers/auth_controller.dart';

class EventController extends GetxController {
  final EventRepository _eventRepository = EventRepository();
  final AuthController _authController = Get.find<AuthController>();
  
  var events = <Event>[].obs;
  var upcomingEvents = <Event>[].obs;
  var organizerEvents = <Event>[].obs;
  var selectedEvent = Rx<Event?>(null);
  var eventRegistrations = <Map<String, dynamic>>[].obs;
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

  void _showSnackbar(String title, String message,
      {Color backgroundColor = Colors.green}) {
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
    isLoading.value = true;
    try {
      final loadedEvents = await _eventRepository.getAllEvents();
      events.value = loadedEvents;
      upcomingEvents.value = loadedEvents
          .where((event) => event.date.isAfter(DateTime.now()))
          .toList();
      final currentUserId = _authController.currentUser.value?.id;
      organizerEvents.value = currentUserId == null
          ? []
          : loadedEvents
              .where((event) => event.organizerId == currentUserId)
              .toList();
    } catch (e) {
      events.clear();
      upcomingEvents.clear();
      organizerEvents.clear();
      _showSnackbar('Erreur', e.toString(), backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadEventDetails(String eventId) async {
    isLoading.value = true;
    try {
      selectedEvent.value = await _eventRepository.getEventById(eventId);
    } catch (e) {
      selectedEvent.value = null;
      _showSnackbar('Erreur', e.toString(), backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createEvent() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final location = locationController.text.trim();
    final venue = cityController.text.trim();
    final dateText = dateController.text.trim();
    final timeText = timeController.text.trim();
    final ticketPrice = double.tryParse(ticketPriceController.text.trim());
    final maxFighters = int.tryParse(maxFightersController.text.trim());

    if (name.isEmpty || dateText.isEmpty || location.isEmpty || venue.isEmpty) {
      _showSnackbar('Erreur',
          'Name, date, location and venue are required.',
          backgroundColor: Colors.red);
      return;
    }

    isCreating.value = true;
    try {
      final data = {
        'name': name,
        if (description.isNotEmpty) 'description': description,
        'location': location,
        'venue': venue,
        'date': _normalizeDate(dateText, timeText),
        if (ticketPrice != null) 'ticketPrice': ticketPrice,
        if (maxFighters != null) 'maxFighters': maxFighters,
        if (_authController.currentUser.value?.id != null)
          'organizerId': _authController.currentUser.value!.id,
      };

      final event = await _eventRepository.createEvent(data);
      events.insert(0, event);
      if (event.date.isAfter(DateTime.now())) {
        upcomingEvents.insert(0, event);
      }
      if (event.organizerId == _authController.currentUser.value?.id) {
        organizerEvents.insert(0, event);
      }

      _showSnackbar('Succès', 'Événement créé avec succès');
      _clearEventForm();
      Get.back();
    } catch (e) {
      _showSnackbar('Erreur', e.toString(), backgroundColor: Colors.red);
    } finally {
      isCreating.value = false;
    }
  }

  String _normalizeDate(String date, String time) {
    if (time.isEmpty) {
      return date;
    }

    final candidate = DateTime.tryParse('$date $time');
    if (candidate != null) {
      return candidate.toIso8601String();
    }

    return date;
  }

  void _clearEventForm() {
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
}
