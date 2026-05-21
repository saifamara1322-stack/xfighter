import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/repositories/admin_repository.dart';
import 'package:xfighter/data/models/user_model.dart';
import 'package:xfighter/data/models/admin_model.dart';

class AdminController extends GetxController {
  final AdminRepository _repo = AdminRepository();

  // ── State ─────────────────────────────────────────────────────────────────
  var admins = <User>[].obs;
  var selectedAdmin = Rx<User?>(null);
  var audit = Rx<AdminAuditResponse?>(null);
  var isLoading = false.obs;
  var isCreating = false.obs;

  var currentPage = 0.obs;
  var totalPages = 1.obs;
  var totalElements = 0.obs;
  final int pageSize = 20;

  // Filter state
  var statusFilter = RxString('');
  var countryFilter = RxString('');

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  var selectedCountryId = RxString('');

  // Change password form
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  // Change email form
  final newEmailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAdmins();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    newEmailController.dispose();
    super.onClose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadAdmins({int page = 0}) async {
    isLoading.value = true;
    try {
      final paged = await _repo.getAllAdmins(
        page: page,
        size: pageSize,
        countryId: countryFilter.value.isNotEmpty ? countryFilter.value : null,
        status: statusFilter.value.isNotEmpty ? statusFilter.value : null,
      );
      admins.value = paged.content;
      currentPage.value = paged.pageNumber;
      totalPages.value = paged.totalPages;
      totalElements.value = paged.totalElements;
    } catch (e) {
      _snack('Error', 'Failed to load admins: $e', color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAdminDetail(String id) async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getAdminById(id),
        _repo.getAdminAudit(id),
      ]);
      selectedAdmin.value = results[0] as User;
      audit.value = results[1] as AdminAuditResponse;
    } catch (e) {
      _snack('Error', 'Failed to load admin details: $e', color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<void> createAdmin() async {
    if (!_validateForm()) return;
    isLoading.value = true;
    try {
      final request = CreateAdminRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        phoneNumber: phoneController.text.isNotEmpty ? phoneController.text : null,
        city: cityController.text.isNotEmpty ? cityController.text : null,
        countryId: selectedCountryId.value,
      );
      final created = await _repo.createAdmin(request);
      admins.add(created);
      _clearForm();
      isCreating.value = false;
      _snack('Success', 'Admin created successfully');
    } catch (e) {
      _snack('Error', 'Failed to create admin: $e', color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Activate / Deactivate ─────────────────────────────────────────────────

  Future<void> activateAdmin(String id) async {
    try {
      final updated = await _repo.activateAdmin(id);
      _replaceInList(updated);
      _snack('Success', 'Admin activated');
    } catch (e) {
      _snack('Error', e.toString(), color: Colors.red);
    }
  }

  Future<void> deactivateAdmin(String id) async {
    try {
      final updated = await _repo.deactivateAdmin(id);
      _replaceInList(updated);
      _snack('Success', 'Admin deactivated');
    } catch (e) {
      _snack('Error', e.toString(), color: Colors.red);
    }
  }

  // ── Password ──────────────────────────────────────────────────────────────

  Future<void> changeAdminPassword(String id) async {
    if (newPasswordController.text.length < 6) {
      _snack('Error', 'Password must be at least 6 characters', color: Colors.red);
      return;
    }
    try {
      await _repo.changeAdminPassword(
        id,
        ChangePasswordRequest(newPassword: newPasswordController.text),
      );
      newPasswordController.clear();
      _snack('Success', 'Password changed');
    } catch (e) {
      _snack('Error', e.toString(), color: Colors.red);
    }
  }

  // ── Email ─────────────────────────────────────────────────────────────────

  Future<void> changeAdminEmail(String id) async {
    if (newEmailController.text.trim().isEmpty) {
      _snack('Error', 'Please enter a new email', color: Colors.red);
      return;
    }
    try {
      final updated = await _repo.changeAdminEmail(
        id,
        ChangeEmailRequest(newEmail: newEmailController.text.trim()),
      );
      _replaceInList(updated);
      newEmailController.clear();
      _snack('Success', 'Email changed');
    } catch (e) {
      _snack('Error', e.toString(), color: Colors.red);
    }
  }

  // ── Pagination ────────────────────────────────────────────────────────────

  void nextPage() {
    if (currentPage.value < totalPages.value - 1) {
      loadAdmins(page: currentPage.value + 1);
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      loadAdmins(page: currentPage.value - 1);
    }
  }

  void applyFilters() => loadAdmins(page: 0);

  void clearFilters() {
    statusFilter.value = '';
    countryFilter.value = '';
    loadAdmins(page: 0);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void toggleCreating() => isCreating.value = !isCreating.value;

  bool _validateForm() {
    if (emailController.text.trim().isEmpty) {
      _snack('Error', 'Email is required', color: Colors.red);
      return false;
    }
    if (passwordController.text.length < 6) {
      _snack('Error', 'Password must be at least 6 characters', color: Colors.red);
      return false;
    }
    if (selectedCountryId.value.isEmpty) {
      _snack('Error', 'Country is required', color: Colors.red);
      return false;
    }
    return true;
  }

  void _clearForm() {
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    phoneController.clear();
    cityController.clear();
    selectedCountryId.value = '';
  }

  void _replaceInList(User updated) {
    final idx = admins.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      admins[idx] = updated;
      admins.refresh();
    }
    if (selectedAdmin.value?.id == updated.id) {
      selectedAdmin.value = updated;
    }
  }

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
