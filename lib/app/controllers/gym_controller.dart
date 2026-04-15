import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/gym_repository.dart';
import '../models/gym_model.dart';
import '../models/fighter_model.dart';
import 'auth_controller.dart';

class GymController extends GetxController {
  final GymRepository _gymRepository = GymRepository();
  final AuthController _authController = Get.find<AuthController>();
  
  var gyms = <Gym>[].obs;
  var userGyms = <Gym>[].obs;
  var selectedGym = Rx<Gym?>(null);
  var gymFighters = <Fighter>[].obs;
  var isLoading = false.obs;
  var isCreating = false.obs;
  
  // Form controllers for gym registration
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final descriptionController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    loadGyms();
    loadUserGyms();
  }
  
  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    cityController.dispose();
    phoneController.dispose();
    emailController.dispose();
    descriptionController.dispose();
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
  
  Future<void> loadGyms() async {
    try {
      isLoading.value = true;
      gyms.value = await _gymRepository.getAllGyms();
    } catch (e) {
      _showSnackbar(
        'Erreur',
        'Impossible de charger les gyms: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadUserGyms() async {
    final user = _authController.currentUser.value;
    if (user == null) return;
    
    try {
      userGyms.value = await _gymRepository.getGymsByOwner(user.id);
    } catch (e) {
      debugPrint('Error loading user gyms: $e');
    }
  }
  
  Future<void> selectGym(String gymId) async {
    try {
      isLoading.value = true;
      selectedGym.value = await _gymRepository.getGymById(gymId);
      if (selectedGym.value != null) {
        await loadGymFighters(gymId);
      }
    } catch (e) {
      _showSnackbar(
        'Erreur',
        'Impossible de charger le gym: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadGymFighters(String gymId) async {
    try {
      gymFighters.value = await _gymRepository.getGymFighters(gymId);
    } catch (e) {
      debugPrint('Error loading gym fighters: $e');
    }
  }
  
  Future<void> registerGym() async {
    if (!_validateForm()) return;
    
    final user = _authController.currentUser.value;
    if (user == null) {
      _showSnackbar('Erreur', 'Vous devez être connecté', backgroundColor: Colors.red);
      return;
    }
    
    try {
      isCreating.value = true;
      
      final gymData = {
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'ownerId': user.id,
        'description': descriptionController.text.trim().isNotEmpty 
            ? descriptionController.text.trim() 
            : null,
      };
      
      await _gymRepository.createGym(gymData);
      
      // Clear form
      _clearForm();
      
      // Refresh lists
      await loadGyms();
      await loadUserGyms();
      
      Get.back(); // Close dialog
      _showSnackbar(
        'Succès',
        'Votre gym a été enregistrée avec succès! En attente de validation.',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      _showSnackbar(
        'Erreur',
        'Impossible d\'enregistrer le gym: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      isCreating.value = false;
    }
  }
  
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer le nom du gym', backgroundColor: Colors.red);
      return false;
    }
    if (addressController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer l\'adresse', backgroundColor: Colors.red);
      return false;
    }
    if (cityController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer la ville', backgroundColor: Colors.red);
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer le numéro de téléphone', backgroundColor: Colors.red);
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer l\'email', backgroundColor: Colors.red);
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showSnackbar('Erreur', 'Email invalide', backgroundColor: Colors.red);
      return false;
    }
    return true;
  }
  
  void _clearForm() {
    nameController.clear();
    addressController.clear();
    cityController.clear();
    phoneController.clear();
    emailController.clear();
    descriptionController.clear();
  }
  
  Future<void> updateGymStatus(String gymId, String status, String? comments) async {
    if (!_authController.isAdmin()) {
      _showSnackbar('Erreur', 'Action non autorisée', backgroundColor: Colors.red);
      return;
    }
    
    try {
      isLoading.value = true;
      await _gymRepository.updateGymStatus(gymId, status, _authController.currentUser.value?.id, comments);
      await loadGyms();
      
      _showSnackbar(
        'Succès',
        'Statut du gym mis à jour',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      _showSnackbar(
        'Erreur',
        'Impossible de mettre à jour le statut: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  List<Gym> get pendingGyms {
    return gyms.where((gym) => gym.status == GymStatus.pending).toList();
  }
  
  List<Gym> get activeGyms {
    return gyms.where((gym) => gym.status == GymStatus.active).toList();
  }
  
  bool get canManageGym {
    final user = _authController.currentUser.value;
    if (user == null) return false;
    return user.role.name == 'admin' || user.role.name == 'organizer' || user.role.name == 'coach';
  }
}