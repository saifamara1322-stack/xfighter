import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/repositories/auth_repository.dart';
import 'package:xfighter/data/repositories/country_repository.dart';
import 'package:xfighter/data/models/user_model.dart';
import 'package:xfighter/data/models/country_model.dart';

/// Roles available for self-registration via the public endpoints.
enum RegisterRole { fighter, referee }

class AuthController extends GetxController with GetTickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();
  final CountryRepository _countryRepository = CountryRepository();

  // ── Observables ────────────────────────────────────────────────────────────
  var currentUser = Rx<User?>(null);
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var countries = <Country>[].obs;
  var selectedCountryId = RxString('');

  // Registration role selector (tab index: 0=Fighter, 1=Referee)
  var registerRoleIndex = 0.obs;
  RegisterRole get registerRole =>
      registerRoleIndex.value == 0 ? RegisterRole.fighter : RegisterRole.referee;

  late TabController registerTabController;

  // ── Form controllers ───────────────────────────────────────────────────────
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  // Fighter-specific
  final categoryController = TextEditingController();
  final weightController = TextEditingController();
  // Referee-specific
  final licenseNumberController = TextEditingController();
  final gradeController = TextEditingController();

  var obscurePassword = true.obs;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    registerTabController = TabController(length: 2, vsync: this);
    registerTabController.addListener(() {
      registerRoleIndex.value = registerTabController.index;
    });
    checkAuthStatus();
    loadCountries();
  }

  @override
  void onClose() {
    registerTabController.dispose();
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    categoryController.dispose();
    weightController.dispose();
    licenseNumberController.dispose();
    gradeController.dispose();
    super.onClose();
  }

  // ── Auth state ─────────────────────────────────────────────────────────────
  Future<void> checkAuthStatus() async {
    isLoggedIn.value = await _authRepository.isLoggedIn();
    if (isLoggedIn.value) {
      try {
        currentUser.value = await _authRepository.getCurrentUser();
      } catch (_) {
        currentUser.value = await _authRepository.getCachedUser();
      }
    }
  }

  Future<void> loadCountries() async {
    try {
      countries.value = await _countryRepository.getAllCountries();
    } catch (_) {
      // Non-critical; countries list is used for registration
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<void> login() async {
    if (!_validateLoginForm()) return;

    isLoading.value = true;
    try {
      await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );
      final user = await _authRepository.getCurrentUser();
      await _authRepository.cacheUser(user);
      currentUser.value = user;
      isLoggedIn.value = true;
      emailController.clear();
      passwordController.clear();

      _showSnackbar('Succès', 'Bienvenue ${user.fullName}!');
      Get.offAllNamed('/dashboard');
    } catch (e) {
      _showSnackbar('Erreur', e.toString(), backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Registration ───────────────────────────────────────────────────────────
  Future<void> register() async {
    if (!_validateRegisterForm()) return;

    isLoading.value = true;
    try {
      if (registerRole == RegisterRole.fighter) {
        await _registerFighter();
      } else {
        await _registerReferee();
      }
      _showSnackbar(
        'Succès',
        'Inscription réussie! Votre compte est en attente de vérification.',
      );
      _clearRegisterForm();
      Get.offAllNamed('/login');
    } catch (e) {
      _showSnackbar('Erreur', e.toString(), backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _registerFighter() async {
    final data = {
      'email': emailController.text.trim(),
      'password': passwordController.text,
      'fullName': fullNameController.text.trim(),
      'phoneNumber': phoneController.text.isNotEmpty ? phoneController.text : null,
      'countryId': selectedCountryId.value,
      'category': categoryController.text.isNotEmpty ? categoryController.text : null,
      'weight': weightController.text.isNotEmpty
          ? double.tryParse(weightController.text)
          : null,
    };
    await _authRepository.registerFighter(data);
  }

  Future<void> _registerReferee() async {
    final data = {
      'email': emailController.text.trim(),
      'password': passwordController.text,
      'fullName': fullNameController.text.trim(),
      'phoneNumber': phoneController.text.isNotEmpty ? phoneController.text : null,
      'countryId': selectedCountryId.value,
      'licenseNumber': licenseNumberController.text.isNotEmpty
          ? licenseNumberController.text
          : null,
      'grade': gradeController.text.isNotEmpty ? gradeController.text : null,
    };
    await _authRepository.registerReferee(data);
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authRepository.logout();
    } catch (_) {
      // Clear local state even if API call fails
    } finally {
      currentUser.value = null;
      isLoggedIn.value = false;
      isLoading.value = false;
      Get.offAllNamed('/login');
    }
  }

  // ── Token refresh ──────────────────────────────────────────────────────────
  Future<bool> refreshAccessToken() async {
    try {
      await _authRepository.refreshToken();
      return true;
    } catch (_) {
      return false;
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool _validateLoginForm() {
    if (emailController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer votre email',
          backgroundColor: Colors.red);
      return false;
    }
    if (passwordController.text.isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer votre mot de passe',
          backgroundColor: Colors.red);
      return false;
    }
    return true;
  }

  bool _validateRegisterForm() {
    if (emailController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer votre email',
          backgroundColor: Colors.red);
      return false;
    }
    if (passwordController.text.length < 6) {
      _showSnackbar('Erreur', 'Le mot de passe doit contenir au moins 6 caractères',
          backgroundColor: Colors.red);
      return false;
    }
    if (fullNameController.text.trim().isEmpty) {
      _showSnackbar('Erreur', 'Veuillez entrer votre nom complet',
          backgroundColor: Colors.red);
      return false;
    }
    if (selectedCountryId.value.isEmpty) {
      _showSnackbar('Erreur', 'Veuillez sélectionner votre pays',
          backgroundColor: Colors.red);
      return false;
    }
    return true;
  }

  void _clearRegisterForm() {
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    phoneController.clear();
    categoryController.clear();
    weightController.clear();
    licenseNumberController.clear();
    gradeController.clear();
    selectedCountryId.value = '';
    registerTabController.index = 0;
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

  // Legacy getters so old views that use selectedRole still compile
  UserRole get selectedRoleValue =>
      registerRole == RegisterRole.fighter ? UserRole.FIGHTER : UserRole.REFEREE;
}