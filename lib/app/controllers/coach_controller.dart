import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/coach_repository.dart';
import '../models/coach_model.dart';
import '../models/fighter_model.dart';
import 'auth_controller.dart';

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
  
  Future<void> loadCoachProfile() async {
    final user = _authController.currentUser.value;
    if (user == null || user.role != 'coach') return;
    
    try {
      isLoading.value = true;
      final coach = await _coachRepository.getCoachByUserId(user.id);
      currentCoach.value = coach;
      
      if (coach != null) {
        specializationController.text = coach.specialization;
        experienceController.text = coach.experience.toString();
        gymController.text = coach.gym ?? '';
        bioController.text = coach.bio ?? '';
        certifications.value = coach.certifications;
        
        await loadCoachFighters(coach.id);
      }
    } catch (e) {
      _showSnackbar('Erreur', 'Impossible de charger le profil: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadAllCoaches() async {
    try {
      coaches.value = await _coachRepository.getAllCoaches();
    } catch (e) {
      print('Error loading coaches: $e');
    }
  }
  
  Future<void> loadCoachFighters(String coachId) async {
    try {
      coachFighters.value = await _coachRepository.getCoachFighters(coachId);
    } catch (e) {
      print('Error loading coach fighters: $e');
    }
  }
  
  Future<void> createOrUpdateProfile() async {
    if (!_validateForm()) return;
    
    final user = _authController.currentUser.value;
    if (user == null) return;
    
    try {
      isLoading.value = true;
      
      final coachData = {
        'userId': user.id,
        'specialization': specializationController.text.trim(),
        'experience': int.parse(experienceController.text),
        'certifications': certifications,
        'gym': gymController.text.trim().isNotEmpty ? gymController.text.trim() : null,
        'bio': bioController.text.trim().isNotEmpty ? bioController.text.trim() : null,
      };
      
      if (currentCoach.value == null) {
        final newCoach = await _coachRepository.createCoach(coachData);
        currentCoach.value = newCoach;
        _showSnackbar('Succès', 'Profil coach créé! En attente de validation.', backgroundColor: Colors.green);
      } else {
        final updatedCoach = await _coachRepository.updateCoach(
          currentCoach.value!.id,
          coachData,
        );
        currentCoach.value = updatedCoach;
        _showSnackbar('Succès', 'Profil mis à jour!', backgroundColor: Colors.green);
      }
      
      isEditing.value = false;
    } catch (e) {
      _showSnackbar('Erreur', 'Erreur: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  void addCertification() {
    if (newCertificationController.text.trim().isNotEmpty) {
      certifications.add(newCertificationController.text.trim());
      newCertificationController.clear();
    }
  }
  
  void removeCertification(int index) {
    certifications.removeAt(index);
  }
  
  Future<void> updateCoachStatus(String coachId, String status) async {
    if (!_authController.isAdmin()) {
      _showSnackbar('Erreur', 'Action non autorisée', backgroundColor: Colors.red);
      return;
    }
    
    try {
      isLoading.value = true;
      await _coachRepository.updateCoachStatus(coachId, status, _authController.currentUser.value?.id);
      await loadAllCoaches();
      await loadCoachProfile();
      
      _showSnackbar('Succès', 'Statut du coach mis à jour', backgroundColor: Colors.green);
    } catch (e) {
      _showSnackbar('Erreur', 'Impossible de mettre à jour: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  bool _validateForm() {
    if (specializationController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer votre spécialisation', backgroundColor: Colors.red);
      return false;
    }
    if (experienceController.text.isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer vos années d\'expérience', backgroundColor: Colors.red);
      return false;
    }
    return true;
  }
  
  void toggleEditMode() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      loadCoachProfile();
    }
  }
  
  List<Coach> get pendingCoaches {
    return coaches.where((c) => c.status == CoachStatus.pending).toList();
  }
  
  List<Coach> get activeCoaches {
    return coaches.where((c) => c.status == CoachStatus.active).toList();
  }
}