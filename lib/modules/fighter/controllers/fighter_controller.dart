import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/repositories/fighter_repository.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';

class FighterController extends GetxController {
  final FighterRepository _fighterRepository = FighterRepository();
  final AuthController _authController = Get.find<AuthController>();
  
  var currentFighter = Rx<Fighter?>(null);
  var isLoading = false.obs;
  var isEditing = false.obs;
  
  // Form controllers for profile editing
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final reachController = TextEditingController();
  final styleController = TextEditingController();
  final gymController = TextEditingController();
  final bioController = TextEditingController();
  final nationalityController = TextEditingController();
  var selectedWeightClass = RxString('');
  var birthDate = Rx<DateTime?>(null);
  
  @override
  void onInit() {
    super.onInit();
    loadFighterProfile();
  }
  
  @override
  void onClose() {
    weightController.dispose();
    heightController.dispose();
    reachController.dispose();
    styleController.dispose();
    gymController.dispose();
    bioController.dispose();
    nationalityController.dispose();
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
  
  Future<void> loadFighterProfile() async {
    final currentUser = _authController.currentUser.value;
    if (currentUser == null) return;
    
    try {
      isLoading.value = true;
      final fighter = await _fighterRepository.getFighterByUserId(currentUser.id);
      currentFighter.value = fighter;
      
      if (fighter != null) {
        weightController.text = fighter.weight.toString();
        heightController.text = fighter.height.toString();
        reachController.text = fighter.reach.toString();
        styleController.text = fighter.style;
        gymController.text = fighter.gym;
        bioController.text = fighter.bio ?? '';
        nationalityController.text = fighter.nationality ?? '';
        selectedWeightClass.value = fighter.weightClass;
        birthDate.value = fighter.birthDate;
      }
    } catch (e) {
      _showSnackbar('Erreur', 'Impossible de charger le profil: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateFighterProfile() async {
    if (currentFighter.value == null) return;
    
    try {
      isLoading.value = true;
      
      final updatedData = {
        'weight': int.tryParse(weightController.text) ?? currentFighter.value!.weight,
        'height': int.tryParse(heightController.text) ?? currentFighter.value!.height,
        'reach': int.tryParse(reachController.text) ?? currentFighter.value!.reach,
        'style': styleController.text,
        'gym': gymController.text,
        'bio': bioController.text,
        'nationality': nationalityController.text,
        'weightClass': selectedWeightClass.value.isNotEmpty 
            ? selectedWeightClass.value 
            : currentFighter.value!.weightClass,
        'birthDate': birthDate.value?.toIso8601String(),
      };
      
      await _fighterRepository.updateFighter(currentFighter.value!.id, updatedData);
      await loadFighterProfile();
      
      _showSnackbar('Succès', 'Profil mis à jour avec succès', backgroundColor: Colors.green);
      isEditing.value = false;
    } catch (e) {
      _showSnackbar('Erreur', 'Échec de la mise à jour: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> createFighterProfile() async {
    final user = _authController.currentUser.value;
    if (user == null) return;
    
    try {
      isLoading.value = true;
      
      final fighterData = {
        'userId': user.id,
        'weight': int.tryParse(weightController.text) ?? 70,
        'height': int.tryParse(heightController.text) ?? 175,
        'reach': int.tryParse(reachController.text) ?? 175,
        'style': styleController.text.isNotEmpty ? styleController.text : 'MMA',
        'gym': gymController.text,
        'bio': bioController.text,
        'nationality': nationalityController.text,
        'weightClass': selectedWeightClass.value.isNotEmpty ? selectedWeightClass.value : 'Lightweight',
        'birthDate': birthDate.value?.toIso8601String(),
        'verified': false,
        'record': {
          'wins': 0,
          'losses': 0,
          'draws': 0,
          'knockouts': 0,
          'submissions': 0,
          'decisions': 0,
        },
      };
      
      await _fighterRepository.createFighter(fighterData);
      await loadFighterProfile();
      
      _showSnackbar('Succès', 'Profil créé avec succès', backgroundColor: Colors.green);
    } catch (e) {
      _showSnackbar('Erreur', 'Échec de la création: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  void toggleEditing() {
    isEditing.value = !isEditing.value;
  }
}