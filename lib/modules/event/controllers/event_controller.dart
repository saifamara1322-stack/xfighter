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
  // ...existing methods...
}
