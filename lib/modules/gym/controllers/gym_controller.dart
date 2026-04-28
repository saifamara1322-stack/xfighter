import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/repositories/gym_repository.dart';
import 'package:xfighter/data/models/gym_model.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';

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
  
  Future<void> loadGyms() async {
    try {
      isLoading.value = true;
      gyms.value = await _gymRepository.getAllGyms();
    } catch (e) {
      _showSnackbar('Erreur', 'Impossible de charger les gyms: $e', backgroundColor: Colors.red);
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
      _showSnackbar('Erreur', 'Impossible de charger vos gyms: $e', backgroundColor: Colors.red);
    }
  }
  
  Future<void> loadGymDetails(String gymId) async {
    try {
      isLoading.value = true;
      selectedGym.value = await _gymRepository.getGymById(gymId);
      if (selectedGym.value != null) {
        gymFighters.value = await _gymRepository.getGymFighters(gymId);
      }
    } catch (e) {
      _showSnackbar('Erreur', 'Impossible de charger les détails: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> createGym() async {
    final user = _authController.currentUser.value;
    if (user == null) return;
    
    if (!_validateForm()) return;
    
    try {
      isLoading.value = true;
      
      final gymData = {
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'description': descriptionController.text.trim(),
        'ownerId': user.id,
        'status': 'pending',
        'verified': false,
        'fighters': [],
      };
      
      await _gymRepository.createGym(gymData);
      await loadGyms();
      await loadUserGyms();
      _clearForm();
      
      _showSnackbar('Succès', 'Gym créé avec succès', backgroundColor: Colors.green);
    } catch (e) {
      _showSnackbar('Erreur', 'Échec de la création: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateGym(String gymId) async {
    if (!_validateForm()) return;
    
    try {
      isLoading.value = true;
      
      final updatedData = {
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'description': descriptionController.text.trim(),
      };
      
      await _gymRepository.updateGym(gymId, updatedData);
      await loadGyms();
      await loadGymDetails(gymId);
      
      _showSnackbar('Succès', 'Gym mis à jour avec succès', backgroundColor: Colors.green);
    } catch (e) {
      _showSnackbar('Erreur', 'Échec de la mise à jour: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
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
  
  void toggleCreating() {
    isCreating.value = !isCreating.value;
  }
}