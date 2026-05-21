import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/repositories/verification_repository.dart';
import 'package:xfighter/data/models/verification_model.dart';

enum VerificationTab { all, fighters, referees }

class VerificationController extends GetxController {
  final VerificationRepository _repo = VerificationRepository();

  // ── State ─────────────────────────────────────────────────────────────────
  var pendingUsers = <Map<String, dynamic>>[].obs;
  var selectedUserDocs = Rx<UserDocumentsResponse?>(null);
  var isLoading = false.obs;
  var isLoadingDocs = false.obs;
  var activeTab = VerificationTab.all.obs;

  var currentPage = 0.obs;
  var totalPages = 1.obs;
  var totalElements = 0.obs;
  final int pageSize = 20;

  // Rejection reason
  final rejectionReasonController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadPending();
  }

  @override
  void onClose() {
    rejectionReasonController.dispose();
    super.onClose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadPending({int page = 0}) async {
    isLoading.value = true;
    selectedUserDocs.value = null;
    try {
      final PendingUserPage result;
      switch (activeTab.value) {
        case VerificationTab.fighters:
          result = await _repo.getPendingFighters(page: page, size: pageSize);
          break;
        case VerificationTab.referees:
          result = await _repo.getPendingReferees(page: page, size: pageSize);
          break;
        case VerificationTab.all:
        default:
          result = await _repo.getPendingUsers(page: page, size: pageSize);
      }
      pendingUsers.value = result.content;
      currentPage.value = result.number;
      totalPages.value = result.totalPages;
      totalElements.value = result.totalElements;
    } catch (e) {
      _snack('Error', 'Failed to load pending users: $e', color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  void switchTab(VerificationTab tab) {
    activeTab.value = tab;
    loadPending(page: 0);
  }

  // ── Documents ─────────────────────────────────────────────────────────────

  Future<void> loadUserDocuments(String userId) async {
    isLoadingDocs.value = true;
    try {
      selectedUserDocs.value = await _repo.getUserDocuments(userId);
    } catch (e) {
      _snack('Error', 'Failed to load documents: $e', color: Colors.red);
    } finally {
      isLoadingDocs.value = false;
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> approveUser(String userId) async {
    try {
      await _repo.approveUser(userId);
      pendingUsers.removeWhere((u) => u['id']?.toString() == userId);
      totalElements.value = (totalElements.value - 1).clamp(0, totalElements.value);
      selectedUserDocs.value = null;
      _snack('Success', 'User approved');
    } catch (e) {
      _snack('Error', e.toString(), color: Colors.red);
    }
  }

  Future<void> rejectUser(String userId) async {
    final reason = rejectionReasonController.text.trim();
    if (reason.length < 10) {
      _snack('Error', 'Rejection reason must be at least 10 characters',
          color: Colors.red);
      return;
    }
    try {
      await _repo.rejectUser(userId, RejectionRequest(reason: reason));
      pendingUsers.removeWhere((u) => u['id']?.toString() == userId);
      totalElements.value = (totalElements.value - 1).clamp(0, totalElements.value);
      selectedUserDocs.value = null;
      rejectionReasonController.clear();
      _snack('Success', 'User rejected');
    } catch (e) {
      _snack('Error', e.toString(), color: Colors.red);
    }
  }

  // ── Pagination ────────────────────────────────────────────────────────────

  void nextPage() {
    if (currentPage.value < totalPages.value - 1) {
      loadPending(page: currentPage.value + 1);
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      loadPending(page: currentPage.value - 1);
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
