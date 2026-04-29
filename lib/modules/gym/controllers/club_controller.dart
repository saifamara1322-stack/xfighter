import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/repositories/club_repository.dart';
import 'package:xfighter/data/models/club_model.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/data/models/coach_model.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';

class ClubController extends GetxController {
  final ClubRepository _clubRepository = ClubRepository();
  final AuthController _authController = Get.find<AuthController>();

  var clubs = <Club>[].obs;
  var myClub = Rx<Club?>(null);
  var selectedClub = Rx<Club?>(null);
  var clubFighters = <Fighter>[].obs;
  var clubCoaches = <Coach>[].obs;
  var isLoading = false.obs;
  var isCreating = false.obs;

  // Pagination state
  var currentPage = 0.obs;
  var totalPages = 1.obs;
  var statusFilter = RxString('');

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAllClubs();
    _tryLoadMyClub();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadAllClubs({String? status}) async {
    isLoading.value = true;
    try {
      final paged =
          await _clubRepository.getAllClubs(status: status);
      clubs.value = paged.content;
      totalPages.value = paged.totalPages;
    } catch (e) {
      _snack('Erreur', 'Impossible de charger les clubs: $e',
          color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _tryLoadMyClub() async {
    final role = _authController.currentUser.value?.role;
    if (role == null) return;
    try {
      myClub.value = await _clubRepository.getMyClub();
    } catch (_) {
      // Not a club account
    }
  }

  Future<void> loadClubDetails(String clubId) async {
    isLoading.value = true;
    try {
      selectedClub.value = await _clubRepository.getClubById(clubId);
      await Future.wait([
        _clubRepository
            .getClubFighters(clubId)
            .then((v) => clubFighters.value = v),
        _clubRepository
            .getClubCoaches(clubId)
            .then((v) => clubCoaches.value = v),
      ]);
    } catch (e) {
      _snack('Erreur', 'Impossible de charger les détails: $e',
          color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Create / Update ────────────────────────────────────────────────────────

  Future<void> createClub() async {
    if (!_validateForm()) return;
    isLoading.value = true;
    try {
      final data = {
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'fullName': fullNameController.text.trim(),
        'clubName': nameController.text.trim(),
        'phoneNumber': phoneController.text.isNotEmpty ? phoneController.text : null,
        'city': cityController.text.isNotEmpty ? cityController.text : null,
        'address': addressController.text.isNotEmpty ? addressController.text : null,
        'description': descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
      };
      final created = await _clubRepository.createClub(data);
      clubs.add(created);
      _clearForm();
      _snack('Succès', 'Club créé avec succès');
    } catch (e) {
      _snack('Erreur', 'Échec de la création: $e', color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMyClub() async {
    isLoading.value = true;
    try {
      final data = {
        'name': nameController.text.isNotEmpty ? nameController.text.trim() : null,
        'city': cityController.text.isNotEmpty ? cityController.text : null,
        'address': addressController.text.isNotEmpty ? addressController.text : null,
        'description': descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
        'phoneNumber': phoneController.text.isNotEmpty ? phoneController.text : null,
      };
      myClub.value = await _clubRepository.updateMyClub(data);
      _snack('Succès', 'Club mis à jour avec succès');
    } catch (e) {
      _snack('Erreur', 'Échec de la mise à jour: $e', color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Invitations ────────────────────────────────────────────────────────────

  Future<void> inviteFighter(String fighterId) async {
    try {
      await _clubRepository.inviteFighter(fighterId);
      _snack('Succès', 'Invitation envoyée au fighter');
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    }
  }

  Future<void> inviteCoach(String coachId) async {
    try {
      await _clubRepository.inviteCoach(coachId);
      _snack('Succès', 'Invitation envoyée au coach');
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    }
  }

  Future<void> respondToFighterRequest(
      String membershipId, String action) async {
    try {
      await _clubRepository.respondToFighterRequest(membershipId, action);
      _snack('Succès',
          action == 'ACCEPT' ? 'Demande acceptée' : 'Demande refusée');
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    }
  }

  Future<void> respondToCoachRequest(
      String membershipId, String action) async {
    try {
      await _clubRepository.respondToCoachRequest(membershipId, action);
      _snack('Succès',
          action == 'ACCEPT' ? 'Demande acceptée' : 'Demande refusée');
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    }
  }

  Future<void> blockClub(String clubId) async {
    try {
      await _clubRepository.blockClub(clubId);
      await loadAllClubs();
      _snack('Succès', 'Club bloqué');
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    }
  }

  Future<void> activateClub(String clubId) async {
    try {
      await _clubRepository.activateClub(clubId);
      await loadAllClubs();
      _snack('Succès', 'Club activé');
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      _snack('Erreur', 'Veuillez entrer le nom du club', color: Colors.red);
      return false;
    }
    return true;
  }

  void _clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    phoneController.clear();
    cityController.clear();
    addressController.clear();
    descriptionController.clear();
  }

  void toggleCreating() => isCreating.value = !isCreating.value;

  void _snack(String title, String msg, {Color color = Colors.green}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        Get.snackbar(title, msg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: color,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(10),
            borderRadius: 10);
      }
    });
  }
}

// Legacy alias so GymController references still compile
@Deprecated('Use ClubController instead')
typedef GymController = ClubController;
