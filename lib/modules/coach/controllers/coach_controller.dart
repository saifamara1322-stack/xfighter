import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/repositories/coach_repository.dart';
import 'package:xfighter/data/models/coach_model.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/data/models/club_model.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';

class CoachController extends GetxController {
  final CoachRepository _coachRepository = CoachRepository();
  final AuthController _authController = Get.find<AuthController>();

  var myFighters = <Fighter>[].obs;
  var myClubs = <Club>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final userId = _authController.currentUser.value?.id;
    if (userId != null) loadCoachData(userId);
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadCoachData(String coachId) async {
    isLoading.value = true;
    try {
      await Future.wait([
        _coachRepository
            .getCoachFighters(coachId)
            .then((v) => myFighters.value = v),
        _coachRepository
            .getCoachClubs(coachId)
            .then((v) => myClubs.value = v),
      ]);
    } catch (e) {
      _snack('Erreur', 'Impossible de charger les données coach: $e',
          color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Fighter relationship ───────────────────────────────────────────────────

  Future<void> requestTrainFighter(String fighterId) async {
    isLoading.value = true;
    try {
      await _coachRepository.requestTrainFighter(fighterId);
      _snack('Succès', 'Demande d\'entraînement envoyée au fighter');
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> respondToFighterRequest(
      String requestId, String action) async {
    isLoading.value = true;
    try {
      await _coachRepository.respondToFighterRequest(requestId, action);
      _snack('Succès',
          action == 'ACCEPT' ? 'Demande acceptée' : 'Demande refusée');
      final userId = _authController.currentUser.value?.id;
      if (userId != null) await loadCoachData(userId);
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelFighterRequest(String requestId) async {
    isLoading.value = true;
    try {
      await _coachRepository.cancelFighterRequest(requestId);
      _snack('Succès', 'Demande annulée');
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Club membership ────────────────────────────────────────────────────────

  Future<void> requestJoinClub(String clubId) async {
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

  Future<void> respondToClubInvitation(
      String membershipId, String action) async {
    isLoading.value = true;
    try {
      await _coachRepository.respondToClubInvitation(membershipId, action);
      _snack('Succès',
          action == 'ACCEPT' ? 'Invitation acceptée' : 'Invitation refusée');
      final userId = _authController.currentUser.value?.id;
      if (userId != null) await loadCoachData(userId);
    } catch (e) {
      _snack('Erreur', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelClubRequest(String membershipId) async {
    isLoading.value = true;
    try {
      await _coachRepository.cancelClubRequest(membershipId);
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
