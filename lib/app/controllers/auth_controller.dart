import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  
  var currentUser = Rx<User?>(null);
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  var selectedRole = UserRole.fighter.obs;
  var obscurePassword = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
  
  Future<void> checkAuthStatus() async {
    isLoggedIn.value = await _authRepository.isLoggedIn();
    if (isLoggedIn.value) {
      currentUser.value = await _authRepository.getCurrentUser();
    }
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
  
  Future<void> login() async {
    if (!_validateLoginForm()) return;
    
    isLoading.value = true;
    try {
      final result = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );
      
      if (result['success'] == true) {
        currentUser.value = result['user'];
        isLoggedIn.value = true;
        emailController.clear();
        passwordController.clear();
        
        _showSnackbar(
          'Succès',
          'Bienvenue ${result['user']?.fullName}!',
          backgroundColor: Colors.green,
        );
        
        Get.offAllNamed('/dashboard');
      } else {
        _showSnackbar(
          'Erreur',
          result['message'] ?? 'Email ou mot de passe incorrect',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      _showSnackbar(
        'Erreur',
        'Une erreur est survenue: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> register() async {
    if (!_validateRegisterForm()) return;
    
    isLoading.value = true;
    try {
      final userData = {
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'role': UserRole.roleToString(selectedRole.value),
        'phoneNumber': phoneController.text.isNotEmpty ? phoneController.text : null,
      };
      
      final result = await _authRepository.register(userData);
      
      if (result['success'] == true) {
        _showSnackbar(
          'Succès',
          result['message'] ?? 'Inscription réussie!',
          backgroundColor: Colors.green,
        );
        
        _clearRegisterForm();
        Get.offAllNamed('/login');
      } else {
        _showSnackbar(
          'Erreur',
          result['message'] ?? 'Échec de l\'inscription',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      _showSnackbar(
        'Erreur',
        'Une erreur est survenue: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> logout() async {
    await _authRepository.logout();
    currentUser.value = null;
    isLoggedIn.value = false;
    
    _showSnackbar(
      'Déconnexion',
      'Vous avez été déconnecté',
      backgroundColor: Colors.blue,
    );
    
    Get.offAllNamed('/login');
  }
  
  bool _validateLoginForm() {
    if (emailController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer votre email', backgroundColor: Colors.red);
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showSnackbar('Erreur', 'Email invalide', backgroundColor: Colors.red);
      return false;
    }
    if (passwordController.text.isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer votre mot de passe', backgroundColor: Colors.red);
      return false;
    }
    return true;
  }
  
  bool _validateRegisterForm() {
    if (firstNameController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer votre prénom', backgroundColor: Colors.red);
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer votre nom', backgroundColor: Colors.red);
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer votre email', backgroundColor: Colors.red);
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showSnackbar('Erreur', 'Email invalide', backgroundColor: Colors.red);
      return false;
    }
    if (passwordController.text.isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer un mot de passe', backgroundColor: Colors.red);
      return false;
    }
    if (passwordController.text.length < 6) {
      _showSnackbar('Erreur', 'Le mot de passe doit contenir au moins 6 caractères', backgroundColor: Colors.red);
      return false;
    }
    return true;
  }
  
  void _clearRegisterForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    phoneController.clear();
    selectedRole.value = UserRole.fighter;
  }
  
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
  
  bool hasRole(UserRole role) {
    return currentUser.value?.role == role;
  }
  
  bool isAdmin() => hasRole(UserRole.admin);
  bool isFighter() => hasRole(UserRole.fighter);
  bool isCoach() => hasRole(UserRole.coach);
  bool isOrganizer() => hasRole(UserRole.organizer);
  bool isReferee() => hasRole(UserRole.referee);
}