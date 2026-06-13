import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/repositories/fighter_repository.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/data/models/coach_model.dart';
import 'package:xfighter/data/models/club_model.dart';
import 'package:xfighter/data/repositories/user_lookup_repository.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';

class FighterController extends GetxController {
  final FighterRepository _fighterRepository = FighterRepository();
  final UserLookupRepository _lookup = UserLookupRepository();
  final AuthController _authController = Get.find<AuthController>();

  var currentFighter = Rx<Fighter?>(null);
  var currentCoach = Rx<Coach?>(null);
  var currentClubs = <Club>[].obs;
  var isLoading = false.obs;

  var pendingClubRequestId = RxString('');
  var pendingCoachRequestId = RxString('');
  

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUserProfile();
  }

  Future<void> refreshProfile() async {
    final userId = _authController.currentUser.value?.id;
    if (userId != null) await loadFighterProfile(userId);
  }

  Future<void> loadFighterProfile(String userId) async {
    isLoading.value = true;
    try {
      final fighter = await _fighterRepository.getFighterByUserId(userId);
      currentFighter.value = fighter;

      final fighterId = fighter.id;
      await Future.wait([
        _loadClubs(fighterId),
        _loadCoach(fighterId),
      ]);
    } catch (e) {
      if (e.toString().contains('Fighter not found')) {
        currentFighter.value = null;
        currentClubs.clear();
        currentCoach.value = null;
      } else {
        _snack('Erreur', 'Impossible de charger le profil: $e', color: Colors.red);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCoach(String fighterId) async {
    try {
      currentCoach.value = await _fighterRepository.getFighterCoach(fighterId);
    } catch (_) {
      currentCoach.value = null;
    }
  }

  Future<void> _loadClubs(String fighterId) async {
    try {
      currentClubs.value = await _fighterRepository.getFighterClubs(fighterId);
    } catch (_) {
      currentClubs.value = [];
    }
  }

  Future<void> _loadCurrentUserProfile() async {
    final userId = _authController.currentUser.value?.id;
    if (userId != null) await loadFighterProfile(userId);
  }

  // Club membership methods (unchanged)
  Future<void> requestJoinClubByEmail(String clubEmail) async {
    isLoading.value = true;
    try {
      final clubId = await _lookup.resolveClubIdByEmail(clubEmail);
      await requestJoinClub(clubId);
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestJoinClub(String clubId) async {
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

  Future<void> respondToClubInvitation(String membershipId, String action) async {
    isLoading.value = true;
    try {
      await _fighterRepository.respondToClubInvitation(membershipId, action);
      _snack('Succès', action == 'ACCEPT' ? 'Invitation acceptée' : 'Invitation refusée');
      await refreshProfile();
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelClubRequest(String membershipId) async {
    isLoading.value = true;
    try {
      await _fighterRepository.cancelClubRequest(membershipId);
      _snack('Succès', 'Demande annulée');
      await refreshProfile();
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // Coach relationship methods
  Future<void> requestCoachByEmail(String coachEmail) async {
    isLoading.value = true;
    try {
      final coachId = await _lookup.resolveCoachIdByEmail(coachEmail);
      await requestCoach(coachId);
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestCoach(String coachId) async {
    isLoading.value = true;
    try {
      await _fighterRepository.requestCoach(coachId);
      _snack('Succès', 'Demande envoyée au coach');
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> respondToCoachRequest(String requestId, String action) async {
    isLoading.value = true;
    try {
      await _fighterRepository.respondToCoachRequest(requestId, action);
      _snack('Succès', action == 'ACCEPT' ? 'Demande acceptée' : 'Demande refusée');
      await refreshProfile();
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelCoachRequest(String requestId) async {
    isLoading.value = true;
    try {
      await _fighterRepository.cancelCoachRequest(requestId);
      _snack('Succès', 'Demande annulée');
      await refreshProfile();
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  void _snack(String title, String msg, {Color color = Colors.green}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        Get.snackbar(
          title,
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: color,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
        );
      }
    });
  }
}