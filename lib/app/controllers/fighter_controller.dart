import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/fighter_repository.dart';
import '../models/fighter_model.dart';
import 'auth_controller.dart';

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
  
  Future<void> loadFighterProfile() async {
    final currentUser = _authController.currentUser.value;
    if (currentUser == null) return;
    
    try {
      isLoading.value = true;
      final fighter = await _fighterRepository.getFighterByUserId(currentUser.id);
      currentFighter.value = fighter;
      
      if (fighter != null) {
        // Populate form fields
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
      _showSnackbar(
        'Erreur',
        'Impossible de charger le profil: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> createOrUpdateProfile() async {
    if (!_validateForm()) return;
    
    try {
      isLoading.value = true;
      final currentUser = _authController.currentUser.value;
      if (currentUser == null) throw Exception('User not logged in');
      
      final fighterData = {
        'userId': currentUser.id,
        'weight': int.parse(weightController.text),
        'weightClass': selectedWeightClass.value,
        'height': int.parse(heightController.text),
        'reach': int.parse(reachController.text),
        'style': styleController.text,
        'gym': gymController.text,
        'bio': bioController.text.isNotEmpty ? bioController.text : null,
        'nationality': nationalityController.text.isNotEmpty ? nationalityController.text : null,
        'birthDate': birthDate.value?.toIso8601String(),
        'coachId': null,
      };
      
      if (currentFighter.value == null) {
        // Create new profile
        final newFighter = await _fighterRepository.createFighter(fighterData);
        currentFighter.value = newFighter;
        _showSnackbar(
          'Succès',
          'Profil de combattant créé avec succès!',
          backgroundColor: Colors.green,
        );
      } else {
        // Update existing profile
        final updatedFighter = await _fighterRepository.updateFighter(
          currentFighter.value!.id,
          fighterData,
        );
        currentFighter.value = updatedFighter;
        _showSnackbar(
          'Succès',
          'Profil mis à jour avec succès!',
          backgroundColor: Colors.green,
        );
      }
      
      isEditing.value = false;
    } catch (e) {
      _showSnackbar(
        'Erreur',
        'Erreur lors de l\'enregistrement: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  bool _validateForm() {
    if (weightController.text.isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer votre poids', backgroundColor: Colors.red);
      return false;
    }
    if (heightController.text.isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer votre taille', backgroundColor: Colors.red);
      return false;
    }
    if (reachController.text.isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer votre allonge', backgroundColor: Colors.red);
      return false;
    }
    if (styleController.text.isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer votre style de combat', backgroundColor: Colors.red);
      return false;
    }
    if (gymController.text.isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer votre gym', backgroundColor: Colors.red);
      return false;
    }
    return true;
  }
  
  void updateWeightClass(int weight) {
    final weightClass = WeightClass.fromWeight(weight);
    selectedWeightClass.value = weightClass.displayName;
  }
  
  void toggleEditMode() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      // Reset form to original values
      loadFighterProfile();
    }
  }
  
  String getWinRateText() {
    if (currentFighter.value == null) return '0%';
    final winRate = currentFighter.value!.winPercentage;
    return '${winRate.toStringAsFixed(1)}%';
  }
  
  List<FightHistoryItem> getFightHistory() {
    // This would come from an API endpoint in production
    // For now, return empty list
    return [];
  }
}

class FightHistoryItem {
  final String opponent;
  final String result;
  final String method;
  final DateTime date;
  final String event;
  
  FightHistoryItem({
    required this.opponent,
    required this.result,
    required this.method,
    required this.date,
    required this.event,
  });
}