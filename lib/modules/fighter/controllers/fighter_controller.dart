import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/repositories/fighter_repository.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/data/models/coach_model.dart';
import 'package:xfighter/data/models/club_model.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';

class FighterController extends GetxController {
  final FighterRepository _fighterRepository = FighterRepository();
  final AuthController _authController = Get.find<AuthController>();

  var currentFighter = Rx<Fighter?>(null);
  var currentCoach = Rx<Coach?>(null);
  var currentClubs = <Club>[].obs;
  var isLoading = false.obs;

  // Pending request IDs (for cancel actions)
  var pendingClubRequestId = RxString('');
  var pendingCoachRequestId = RxString('');

  @override
  void onInit() {
    super.onInit();
    final userId = _authController.currentUser.value?.id;
    if (userId != null) loadFighterProfile(userId);
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadFighterProfile(String fighterId) async {
    isLoading.value = true;
    try {
      currentFighter.value =
          await _fighterRepository.getFighterProfile(fighterId);
      await Future.wait([
        _loadCoach(fighterId),
        _loadClubs(fighterId),
      ]);
    } catch (e) {
      _snack('Erreur', 'Impossible de charger le profil: $e',
          color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCoach(String fighterId) async {
    try {
      currentCoach.value =
          await _fighterRepository.getFighterCoach(fighterId);
    } catch (_) {
      currentCoach.value = null;
    }
  }

  Future<void> _loadClubs(String fighterId) async {
    try {
      currentClubs.value =
          await _fighterRepository.getFighterClubs(fighterId);
    } catch (_) {
      currentClubs.value = [];
    }
  }

  // ── Club membership ────────────────────────────────────────────────────────

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

  Future<void> respondToClubInvitation(
      String membershipId, String action) async {
    isLoading.value = true;
    try {
      await _fighterRepository.respondToClubInvitation(membershipId, action);
      _snack('Succès',
          action == 'ACCEPT' ? 'Invitation acceptée' : 'Invitation refusée');
      final userId = _authController.currentUser.value?.id;
      if (userId != null) await loadFighterProfile(userId);
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
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Coach relationship ─────────────────────────────────────────────────────

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

  Future<void> respondToCoachRequest(
      String requestId, String action) async {
    isLoading.value = true;
    try {
      await _fighterRepository.respondToCoachRequest(requestId, action);
      _snack('Succès',
          action == 'ACCEPT' ? 'Demande acceptée' : 'Demande refusée');
      final userId = _authController.currentUser.value?.id;
      if (userId != null) await loadFighterProfile(userId);
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
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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