import 'package:get/get.dart';
import 'dart:io';
import 'package:xfighter/data/models/document_model.dart';
import 'package:xfighter/data/models/user_model.dart';
import 'package:xfighter/data/repositories/document_repository.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';

class DocumentsController extends GetxController {
  final _repo = DocumentRepository();
  final authController = Get.find<AuthController>();

  final userDocs = Rx<UserDocumentsDTO?>(null);
  final isLoading = false.obs;
  final uploadProgress = <String, bool>{}.obs;
  final fighterIdCard = Rx<File?>(null);
  final fighterMedicalCertificate = Rx<File?>(null);
  final fighterFederalLicense = Rx<File?>(null);

  bool get hasAllFighterDocuments =>
      fighterIdCard.value != null &&
      fighterMedicalCertificate.value != null &&
      fighterFederalLicense.value != null;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      userDocs.value = await _repo.getMyDocuments();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load documents: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadProfileImage(File file) async {
    await _upload('profile-image', () => _repo.uploadProfileImage(file));
  }

  Future<void> deleteProfileImage() async {
    await _delete('profile-image', _repo.deleteProfileImage);
  }

  Future<void> uploadIdCard(File file) async {
    await _upload('id-card', () => _repo.uploadIdCard(file));
  }

  Future<void> deleteIdCard() async {
    await _delete('id-card', _repo.deleteIdCard);
  }

  Future<void> uploadMedicalCertificate(File file) async {
    await _upload(
      'medical-certificate',
      () => _repo.uploadMedicalCertificate(file),
    );
  }

  Future<void> deleteMedicalCertificate() async {
    await _delete('medical-certificate', _repo.deleteMedicalCertificate);
  }

  Future<void> uploadFederalLicense(File file) async {
    await _upload('federal-license', () => _repo.uploadFederalLicense(file));
  }

  Future<void> deleteFederalLicense() async {
    await _delete('federal-license', _repo.deleteFederalLicense);
  }

  void setFighterIdCard(File file) {
    fighterIdCard.value = file;
  }

  void setFighterMedicalCertificate(File file) {
    fighterMedicalCertificate.value = file;
  }

  void setFighterFederalLicense(File file) {
    fighterFederalLicense.value = file;
  }

  void clearFighterIdCard() {
    fighterIdCard.value = null;
  }

  void clearFighterMedicalCertificate() {
    fighterMedicalCertificate.value = null;
  }

  void clearFighterFederalLicense() {
    fighterFederalLicense.value = null;
  }

  void clearFighterDocumentSelection() {
    clearFighterIdCard();
    clearFighterMedicalCertificate();
    clearFighterFederalLicense();
  }

  Future<void> submitFighterDocuments() async {
    final idCard = fighterIdCard.value;
    final medical = fighterMedicalCertificate.value;
    final federal = fighterFederalLicense.value;
    if (idCard == null || medical == null || federal == null) {
      Get.snackbar(
        'Missing documents',
        'Please select all required fighter documents',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final status = authController.currentUser.value?.status;
    if (status != UserStatus.NODOCS && status != UserStatus.REFUSED) {
      Get.snackbar(
        'Documents locked',
        'Documents cannot be submitted while this account is ${status?.displayName ?? 'unavailable'}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    uploadProgress['fighter-documents'] = true;
    try {
      if (status == UserStatus.REFUSED) {
        await _repo.resubmitFighterDocuments(
          idCard: idCard,
          medicalCertificate: medical,
          federalLicense: federal,
        );
      } else {
        await _repo.submitFighterDocuments(
          idCard: idCard,
          medicalCertificate: medical,
          federalLicense: federal,
        );
      }

      clearFighterDocumentSelection();
      Get.snackbar(
        'Success',
        status == UserStatus.REFUSED
            ? 'Documents resubmitted successfully'
            : 'Documents submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      await load();
      await authController.checkAuthStatus();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      uploadProgress['fighter-documents'] = false;
      isLoading.value = false;
    }
  }

  Future<void> uploadLicense(File file) async {
    await _upload('license', () => _repo.uploadLicense(file));
  }

  Future<void> deleteLicense() async {
    await _delete('license', _repo.deleteLicense);
  }

  Future<void> resubmitFighter(File idCard, File medical, File federal) async {
    isLoading.value = true;
    try {
      await _repo.resubmitFighterDocuments(
        idCard: idCard,
        medicalCertificate: medical,
        federalLicense: federal,
      );
      Get.snackbar(
        'Success',
        'Documents resubmitted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      await load();
      // Inform auth controller to refresh current user status
      await authController.checkAuthStatus();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resubmitReferee(File idCard, File license) async {
    isLoading.value = true;
    try {
      await _repo.resubmitRefereeDocuments(idCard: idCard, license: license);
      Get.snackbar(
        'Success',
        'Documents resubmitted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      await load();
      await authController.checkAuthStatus();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _upload(String key, Future<dynamic> Function() action) async {
    uploadProgress[key] = true;
    try {
      await action();
      Get.snackbar(
        'Success',
        'File uploaded successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      await load();
    } catch (e) {
      Get.snackbar(
        'Upload failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      uploadProgress[key] = false;
    }
  }

  Future<void> _delete(String key, Future<void> Function() action) async {
    uploadProgress[key] = true;
    try {
      await action();
      Get.snackbar(
        'Deleted',
        'File removed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      await load();
    } catch (e) {
      Get.snackbar(
        'Delete failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      uploadProgress[key] = false;
    }
  }
}
