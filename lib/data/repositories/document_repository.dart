import 'dart:io';
import 'package:xfighter/data/repositories/api_client.dart';
import 'package:xfighter/data/models/document_model.dart';

class DocumentRepository {
  final ApiClient _api = ApiClient();

  // ── My documents ──────────────────────────────────────────────────────────

  Future<UserDocumentsDTO> getMyDocuments() async {
    final body = await _api.get('/documents/me');
    return UserDocumentsDTO.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Profile image ─────────────────────────────────────────────────────────

  Future<Map<String, String>> uploadProfileImage(File file) async {
    final body = await _api.uploadFile('/documents/profile-image',
        file: file, fieldName: 'file');
    return Map<String, String>.from(body['data'] as Map? ?? {});
  }

  Future<void> deleteProfileImage() async {
    await _api.delete('/documents/profile-image');
  }

  // ── ID Card ───────────────────────────────────────────────────────────────

  Future<Map<String, String>> uploadIdCard(File file) async {
    final body =
        await _api.uploadFile('/documents/id-card', file: file, fieldName: 'file');
    return Map<String, String>.from(body['data'] as Map? ?? {});
  }

  Future<void> deleteIdCard() async {
    await _api.delete('/documents/id-card');
  }

  // ── Medical certificate (Fighter) ─────────────────────────────────────────

  Future<Map<String, String>> uploadMedicalCertificate(File file) async {
    final body = await _api.uploadFile('/documents/medical-certificate',
        file: file, fieldName: 'file');
    return Map<String, String>.from(body['data'] as Map? ?? {});
  }

  Future<void> deleteMedicalCertificate() async {
    await _api.delete('/documents/medical-certificate');
  }

  // ── Federal license (Fighter) ─────────────────────────────────────────────

  Future<Map<String, String>> uploadFederalLicense(File file) async {
    final body = await _api.uploadFile('/documents/federal-license',
        file: file, fieldName: 'file');
    return Map<String, String>.from(body['data'] as Map? ?? {});
  }

  Future<void> deleteFederalLicense() async {
    await _api.delete('/documents/federal-license');
  }

  // ── License (Referee) ─────────────────────────────────────────────────────

  Future<Map<String, String>> uploadLicense(File file) async {
    final body =
        await _api.uploadFile('/documents/license', file: file, fieldName: 'file');
    return Map<String, String>.from(body['data'] as Map? ?? {});
  }

  Future<void> deleteLicense() async {
    await _api.delete('/documents/license');
  }

  // ── Resubmit (Fighter) ────────────────────────────────────────────────────

  Future<Map<String, String>> resubmitFighterDocuments({
    required File idCard,
    required File medicalCertificate,
    required File federalLicense,
  }) async {
    final body = await _api.uploadFiles('/documents/resubmit/fighter', {
      'idCard': idCard,
      'medicalCertificate': medicalCertificate,
      'federalLicense': federalLicense,
    });
    return Map<String, String>.from(body['data'] as Map? ?? {});
  }

  // ── Resubmit (Referee) ────────────────────────────────────────────────────

  Future<Map<String, String>> resubmitRefereeDocuments({
    required File idCard,
    required File license,
  }) async {
    final body = await _api.uploadFiles('/documents/resubmit/referee', {
      'idCard': idCard,
      'license': license,
    });
    return Map<String, String>.from(body['data'] as Map? ?? {});
  }

  // ── Club-on-behalf-of-fighter ─────────────────────────────────────────────

  Future<Map<String, String>> clubUploadFighterProfileImage(
      String fighterId, File file) async {
    final body = await _api.uploadFile(
        '/documents/club/fighter/$fighterId/profile-image',
        file: file,
        fieldName: 'file');
    return Map<String, String>.from(body['data'] as Map? ?? {});
  }

  Future<Map<String, String>> clubUploadFighterIdCard(
      String fighterId, File file) async {
    final body = await _api.uploadFile(
        '/documents/club/fighter/$fighterId/id-card',
        file: file,
        fieldName: 'file');
    return Map<String, String>.from(body['data'] as Map? ?? {});
  }

  Future<Map<String, String>> clubUploadFighterMedicalCertificate(
      String fighterId, File file) async {
    final body = await _api.uploadFile(
        '/documents/club/fighter/$fighterId/medical-certificate',
        file: file,
        fieldName: 'file');
    return Map<String, String>.from(body['data'] as Map? ?? {});
  }

  Future<Map<String, String>> clubUploadFighterFederalLicense(
      String fighterId, File file) async {
    final body = await _api.uploadFile(
        '/documents/club/fighter/$fighterId/federal-license',
        file: file,
        fieldName: 'file');
    return Map<String, String>.from(body['data'] as Map? ?? {});
  }

  Future<void> clubDeleteFighterProfileImage(String fighterId) async {
    await _api.delete('/documents/club/fighter/$fighterId/profile-image');
  }

  Future<void> clubDeleteFighterIdCard(String fighterId) async {
    await _api.delete('/documents/club/fighter/$fighterId/id-card');
  }

  Future<void> clubDeleteFighterMedicalCertificate(String fighterId) async {
    await _api.delete('/documents/club/fighter/$fighterId/medical-certificate');
  }

  Future<void> clubDeleteFighterFederalLicense(String fighterId) async {
    await _api.delete('/documents/club/fighter/$fighterId/federal-license');
  }
}
