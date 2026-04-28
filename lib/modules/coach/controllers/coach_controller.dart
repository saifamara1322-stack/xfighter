import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/coach_repository.dart';
import '../../../data/models/coach_model.dart';
import '../../../data/models/fighter_model.dart';
import '../../auth/controllers/auth_controller.dart';

class CoachController extends GetxController {
  final CoachRepository _coachRepository = CoachRepository();
  final AuthController _authController = Get.find<AuthController>();
  
  var currentCoach = Rx<Coach?>(null);
  var coaches = <Coach>[].obs;
  var coachFighters = <Fighter>[].obs;
  var isLoading = false.obs;
  var isEditing = false.obs;
  
  // Form controllers
  final specializationController = TextEditingController();
  final experienceController = TextEditingController();
  final gymController = TextEditingController();
  final bioController = TextEditingController();
  var certifications = <String>[].obs;
  final newCertificationController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    loadCoachProfile();
    if (_authController.isAdmin()) {
      loadAllCoaches();
    }
  }
  
  @override
  void onClose() {
    specializationController.dispose();
    experienceController.dispose();
    gymController.dispose();
    bioController.dispose();
    newCertificationController.dispose();
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
