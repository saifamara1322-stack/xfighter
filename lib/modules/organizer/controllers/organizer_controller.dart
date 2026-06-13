import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/repositories/organizer_repository.dart';
import 'package:xfighter/data/models/user_model.dart';
import 'package:xfighter/data/models/organizer_model.dart';
import 'package:xfighter/data/models/admin_model.dart';

class OrganizerController extends GetxController {
  final OrganizerRepository _repo = OrganizerRepository();

  // ── State ─────────────────────────────────────────────────────────────────
  var organizers = <User>[].obs;
  var selectedOrganizer = Rx<User?>(null);
  var isLoading = false.obs;
  var isCreating = false.obs;

  var currentPage = 0.obs;
  var totalPages = 1.obs;
  var totalElements = 0.obs;
  final int pageSize = 20;

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();

  // Change password
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadOrganizers();
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
    super.onClose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadOrganizers({int page = 0}) async {
    isLoading.value = true;
    try {
      final paged = await _repo.getAllOrganizers(page: page, size: pageSize);
      organizers.value = paged.content;
      currentPage.value = paged.pageNumber;
      totalPages.value = paged.totalPages;
      totalElements.value = paged.totalElements;
    } catch (e) {
      _snack('Error', 'Failed to load organizers: $e', color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOrganizerDetail(String id) async {
    isLoading.value = true;
    try {
      selectedOrganizer.value = await _repo.getOrganizerById(id);
    } catch (e) {
      _snack('Error', 'Failed to load organizer: $e', color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<void> createOrganizer() async {
    if (!_validateForm()) return;
    isLoading.value = true;
    try {
      final request = CreateOrganizerRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        phoneNumber:
            phoneController.text.isNotEmpty ? phoneController.text : null,
        city: cityController.text.isNotEmpty ? cityController.text : null,
      );
      final created = await _repo.createOrganizer(request);
      organizers.add(created);
      _clearForm();
      isCreating.value = false;
      _snack('Success', 'Organizer created successfully');
      if (Get.isDialogOpen ?? false) Get.back();
    } catch (e) {
      _snack('Error', 'Failed to create organizer: $e', color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Block / Unblock ───────────────────────────────────────────────────────

  Future<void> blockOrganizer(String id) async {
    try {
      final updated = await _repo.blockOrganizer(id);
      _replaceInList(updated);
      _snack('Success', 'Organizer blocked');
    } catch (e) {
      _snack('Error', e.toString(), color: Colors.red);
    }
  }

  Future<void> unblockOrganizer(String id) async {
    try {
      final updated = await _repo.unblockOrganizer(id);
      _replaceInList(updated);
      _snack('Success', 'Organizer unblocked');
    } catch (e) {
      _snack('Error', e.toString(), color: Colors.red);
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<void> updateOrganizer(String id) async {
    isLoading.value = true;
    try {
      final request = UpdateOrganizerRequest(
        fullName: fullNameController.text.isNotEmpty
            ? fullNameController.text.trim()
            : null,
        phoneNumber:
            phoneController.text.isNotEmpty ? phoneController.text : null,
        city: cityController.text.isNotEmpty ? cityController.text : null,
      );
      final updated = await _repo.updateOrganizer(id, request);
      _replaceInList(updated);
      _snack('Success', 'Organizer updated');
    } catch (e) {
      _snack('Error', e.toString(), color: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Pagination ────────────────────────────────────────────────────────────

  void nextPage() {
    if (currentPage.value < totalPages.value - 1) {
      loadOrganizers(page: currentPage.value + 1);
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      loadOrganizers(page: currentPage.value - 1);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void toggleCreating() => isCreating.value = !isCreating.value;

  bool _validateForm() {
    if (emailController.text.trim().isEmpty) {
      _snack('Error', 'Email is required', color: Colors.red);
      return false;
    }
    if (passwordController.text.length < 6) {
      _snack('Error', 'Password must be at least 6 characters',
          color: Colors.red);
      return false;
    }
    if (fullNameController.text.trim().isEmpty) {
      _snack('Error', 'Full name is required', color: Colors.red);
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
  }

  void _replaceInList(User updated) {
    final idx = organizers.indexWhere((o) => o.id == updated.id);
    if (idx != -1) {
      organizers[idx] = updated;
      organizers.refresh();
    }
    if (selectedOrganizer.value?.id == updated.id) {
      selectedOrganizer.value = updated;
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
