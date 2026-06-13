import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/repositories/club_repository.dart';
import 'package:xfighter/data/repositories/fighter_repository.dart';
import 'package:xfighter/data/repositories/coach_repository.dart';
import 'package:xfighter/data/models/club_model.dart';
import 'package:xfighter/data/models/user_model.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/data/models/coach_model.dart';
import 'package:xfighter/data/repositories/user_lookup_repository.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';

class ClubController extends GetxController {
  final ClubRepository _clubRepository = ClubRepository();
  final FighterRepository _fighterRepository = FighterRepository();
  final CoachRepository _coachRepository = CoachRepository();
  final UserLookupRepository _lookup = UserLookupRepository();
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
  final logoUrlController = TextEditingController();


  var searchedClub = Rx<Club?>(null);
  var isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadClubs();
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
      logoUrlController.dispose();
    super.onClose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  /// Loads clubs visible to the current user based on API capabilities.
  Future<void> loadClubs({String? status}) async {
    isLoading.value = true;
    try {
      final user = _authController.currentUser.value;
      if (user == null) {
        clubs.clear();
        return;
      }

      switch (user.role) {
        case UserRole.CLUB:
          final club = await _clubRepository.getMyClub();
          myClub.value = club;
          clubs.value = [club];
          break;
        case UserRole.COACH:
          clubs.value = await _coachRepository.getCoachClubs(user.id);
          break;
        case UserRole.FIGHTER:
          clubs.value = await _fighterRepository.getFighterClubs(user.id);
          break;
        default:
          // No list-all-clubs endpoint in the API — admin/organizer browse by ID.
          clubs.clear();
          try {
            final paged =
                await _clubRepository.getAllClubs(status: status);
            clubs.value = paged.content;
            totalPages.value = paged.totalPages;
          } catch (_) {
            clubs.clear();
          }
      }
    } catch (e) {
      clubs.clear();
      _snack('Erreur', 'Impossible de charger les clubs: $e',
          color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchClubByEmail(String email) async {
    if (email.trim().isEmpty) return;
    isSearching.value = true;
    try {
      searchedClub.value = await _lookup.resolveClubByEmail(email);
    } catch (e) {
      searchedClub.value = null;
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isSearching.value = false;
    }
  }

  /// Legacy UUID search — kept for admin tooling.
  Future<void> searchClubById(String clubId) async {
    if (clubId.trim().isEmpty) return;
    isSearching.value = true;
    try {
      searchedClub.value = await _clubRepository.getClubProfile(clubId.trim());
    } catch (e) {
      searchedClub.value = null;
      _snack('Erreur', 'Club introuvable: $e', color: Colors.red);
    } finally {
      isSearching.value = false;
    }
  }

  /// Legacy alias kept for existing views.
  Future<void> loadAllClubs({String? status}) => loadClubs(status: status);

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
      'description': descriptionController.text.isNotEmpty ? descriptionController.text : null,
      'logoUrl': logoUrlController.text.isNotEmpty ? logoUrlController.text.trim() : null,
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

  Future<void> inviteFighterByEmail(String email) async {
    isLoading.value = true;
    try {
      final fighterId = await _lookup.resolveFighterIdByEmail(email);
      await inviteFighter(fighterId);
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> inviteCoachByEmail(String email) async {
    isLoading.value = true;
    try {
      final coachId = await _lookup.resolveCoachIdByEmail(email);
      await inviteCoach(coachId);
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

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

  Future<void> requestJoinClubForCurrentFighterByEmail(String clubEmail) async {
    isLoading.value = true;
    try {
      final clubId = await _lookup.resolveClubIdByEmail(clubEmail);
      await requestJoinClubForCurrentFighter(clubId);
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestJoinClubForCurrentCoachByEmail(String clubEmail) async {
    isLoading.value = true;
    try {
      final clubId = await _lookup.resolveClubIdByEmail(clubEmail);
      await requestJoinClubForCurrentCoach(clubId);
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestJoinClubForCurrentFighter(String clubId) async {
    isLoading.value = true;
    try {
      await _fighterRepository.requestJoinClub(clubId);
      _snack('Succès', 'Demande d\'adhésion envoyée');
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestJoinClubForCurrentCoach(String clubId) async {
    isLoading.value = true;
    try {
      await _coachRepository.requestJoinClub(clubId);
      _snack('Succès', 'Demande d\'adhésion envoyée');
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

bool _validateForm() {
  if (nameController.text.trim().isEmpty) {
    _snack('Erreur', 'Veuillez entrer le nom du club', color: Colors.red);
    return false;
  }
  if (emailController.text.trim().isEmpty) {
    _snack('Erreur', 'L\'email est requis', color: Colors.red);
    return false;
  }
  if (passwordController.text.trim().isEmpty) {
    _snack('Erreur', 'Le mot de passe est requis', color: Colors.red);
    return false;
  }
  if (fullNameController.text.trim().isEmpty) {
    _snack('Erreur', 'Le nom complet est requis', color: Colors.red);
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
      logoUrlController.clear();   
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
