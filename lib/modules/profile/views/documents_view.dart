import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:xfighter/modules/profile/controllers/documents_controller.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';
import 'package:xfighter/data/models/user_model.dart';
import 'package:xfighter/data/models/document_model.dart';

class DocumentsView extends StatelessWidget {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DocumentsController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'MY DOCUMENTS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (c.isLoading.value && c.userDocs.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE31837)),
          );
        }

        final user = authController.currentUser.value;
        if (user == null) return const SizedBox.shrink();

        final docs = c.userDocs.value;
        final role = user.role;
        final docStatus = user.status;

        return RefreshIndicator(
          color: const Color(0xFFE31837),
          backgroundColor: const Color(0xFF0D0D1A),
          onRefresh: c.load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _StatusBanner(status: docStatus),
              const SizedBox(height: 24),

              // Profile Image - All Roles
              _DocSlot(
                title: 'Profile Image',
                icon: Icons.person_outline,
                url: docs?.profileImageUrl,
                status: null, // Profile image doesn't usually get rejected
                isUploading: c.uploadProgress['profile-image'] ?? false,
                onUpload: (f) => c.uploadProfileImage(f),
                onDelete: () => c.deleteProfileImage(),
                docKey: 'profile-image',
              ),

              if (role == UserRole.FIGHTER) ...[
                const SizedBox(height: 24),
                const _SectionTitle('FIGHTER DOCUMENTS'),
                const SizedBox(height: 16),
                _FighterDocumentsSection(
                  controller: c,
                  docs: docs,
                  status: docStatus,
                ),
              ],

              if (role == UserRole.REFEREE || role == UserRole.COACH) ...[
                const SizedBox(height: 24),
                _SectionTitle(
                  role == UserRole.COACH
                      ? 'COACH DOCUMENTS'
                      : 'REFEREE DOCUMENTS',
                ),
                const SizedBox(height: 16),
                _DocSlot(
                  title: 'ID Card / Passport',
                  icon: Icons.badge_outlined,
                  url: docs?.idCardUrl,
                  status: docStatus,
                  isUploading: c.uploadProgress['id-card'] ?? false,
                  onUpload: (f) => c.uploadIdCard(f),
                  onDelete: () => c.deleteIdCard(),
                  docKey: 'id-card',
                ),
                _DocSlot(
                  title: role == UserRole.COACH
                      ? 'Coach License'
                      : 'Referee License',
                  icon: Icons.assignment_ind_outlined,
                  url: docs?.licenseUrl,
                  status: docStatus,
                  isUploading: c.uploadProgress['license'] ?? false,
                  onUpload: (f) => c.uploadLicense(f),
                  onDelete: () => c.deleteLicense(),
                  docKey: 'license',
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final UserStatus? status;
  const _StatusBanner({this.status});

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();

    Color bgColor = Colors.transparent;
    Color textColor = Colors.white;
    IconData icon = Icons.info_outline;
    String text = '';

    switch (status!) {
      case UserStatus.PENDING:
        bgColor = Colors.orange.withValues(alpha: 0.15);
        textColor = Colors.orange;
        icon = Icons.pending_actions;
        text = 'Documents are under review. Please wait for admin approval.';
        break;
      case UserStatus.ACTIVE:
        bgColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green;
        icon = Icons.verified;
        text = 'Your documents have been approved!';
        break;
      case UserStatus.REFUSED:
        bgColor = const Color(0xFFE31837).withValues(alpha: 0.15);
        textColor = const Color(0xFFE31837);
        icon = Icons.error_outline;
        text =
            'Some documents were rejected. Please upload valid files and resubmit.';
        break;
      case UserStatus.NODOCS:
        bgColor = Colors.blue.withValues(alpha: 0.15);
        textColor = Colors.blue;
        icon = Icons.upload_file;
        text = 'Please upload your mandatory documents to get verified.';
        break;
      case UserStatus.DISABLED:
        bgColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey;
        icon = Icons.block;
        text = 'Your account is currently disabled.';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 16, color: const Color(0xFFE31837)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _FighterDocumentsSection extends StatelessWidget {
  final DocumentsController controller;
  final UserDocumentsDTO? docs;
  final UserStatus status;

  const _FighterDocumentsSection({
    required this.controller,
    required this.docs,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    if (status == UserStatus.NODOCS || status == UserStatus.REFUSED) {
      return _FighterSubmissionForm(
        controller: controller,
        isResubmission: status == UserStatus.REFUSED,
      );
    }

    return _FighterReadOnlyDocuments(docs: docs, status: status);
  }
}

class _FighterSubmissionForm extends StatelessWidget {
  final DocumentsController controller;
  final bool isResubmission;

  const _FighterSubmissionForm({
    required this.controller,
    required this.isResubmission,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSubmitting =
          controller.uploadProgress['fighter-documents'] ?? false;

      return Column(
        children: [
          _DocSlot(
            title: 'ID Card / Passport',
            icon: Icons.badge_outlined,
            selectedFileName: _fileName(controller.fighterIdCard.value),
            status: null,
            isUploading: isSubmitting,
            onUpload: controller.setFighterIdCard,
            onDelete: controller.clearFighterIdCard,
            docKey: 'id-card',
          ),
          _DocSlot(
            title: 'Medical Certificate',
            icon: Icons.medical_information_outlined,
            selectedFileName: _fileName(
              controller.fighterMedicalCertificate.value,
            ),
            status: null,
            isUploading: isSubmitting,
            onUpload: controller.setFighterMedicalCertificate,
            onDelete: controller.clearFighterMedicalCertificate,
            docKey: 'medical-certificate',
          ),
          _DocSlot(
            title: 'Federal License',
            icon: Icons.card_membership,
            selectedFileName: _fileName(controller.fighterFederalLicense.value),
            status: null,
            isUploading: isSubmitting,
            onUpload: controller.setFighterFederalLicense,
            onDelete: controller.clearFighterFederalLicense,
            docKey: 'federal-license',
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSubmitting || !controller.hasAllFighterDocuments
                  ? null
                  : controller.submitFighterDocuments,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837),
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white38,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(
                isResubmission ? 'RESUBMIT DOCUMENTS' : 'SUBMIT DOCUMENTS',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _FighterReadOnlyDocuments extends StatelessWidget {
  final UserDocumentsDTO? docs;
  final UserStatus status;

  const _FighterReadOnlyDocuments({required this.docs, required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DocSlot(
          title: 'ID Card / Passport',
          icon: Icons.badge_outlined,
          url: docs?.idCardUrl,
          status: status,
          isUploading: false,
          canEdit: false,
          docKey: 'id-card',
        ),
        _DocSlot(
          title: 'Medical Certificate',
          icon: Icons.medical_information_outlined,
          url: docs?.medicalCertificateUrl,
          status: status,
          isUploading: false,
          canEdit: false,
          docKey: 'medical-certificate',
        ),
        _DocSlot(
          title: 'Federal License',
          icon: Icons.card_membership,
          url: docs?.federalLicenseUrl,
          status: status,
          isUploading: false,
          canEdit: false,
          docKey: 'federal-license',
        ),
      ],
    );
  }
}

String? _fileName(File? file) {
  final path = file?.path;
  if (path == null || path.isEmpty) return null;
  return path.split(RegExp(r'[\\/]')).last;
}

class _DocSlot extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? url;
  final String? selectedFileName;
  final UserStatus? status;
  final bool isUploading;
  final Function(File)? onUpload;
  final VoidCallback? onDelete;
  final String docKey;
  final bool canEdit;

  const _DocSlot({
    required this.title,
    required this.icon,
    this.url,
    this.selectedFileName,
    this.status,
    required this.isUploading,
    this.onUpload,
    this.onDelete,
    required this.docKey,
    this.canEdit = true,
  });

  Future<void> _pick() async {
    if (!canEdit || onUpload == null) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onUpload!(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasRemoteFile = url != null && url!.isNotEmpty;
    final hasSelectedFile =
        selectedFileName != null && selectedFileName!.isNotEmpty;
    final hasFile = hasRemoteFile || hasSelectedFile;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE31837).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFE31837)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                if (isUploading)
                  const Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFE31837),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Uploading...',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  )
                else if (hasSelectedFile)
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          selectedFileName!,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else if (hasRemoteFile)
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Uploaded',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                else
                  const Text(
                    'No file chosen',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (!isUploading && canEdit)
            hasFile
                ? PopupMenuButton<String>(
                    color: const Color(0xFF1A1A2E),
                    icon: const Icon(Icons.more_vert, color: Colors.white54),
                    onSelected: (v) {
                      if (v == 'replace') _pick();
                      if (v == 'delete') onDelete?.call();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'replace',
                        child: Text(
                          'Replace file',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        enabled: onDelete != null,
                        child: const Text(
                          'Delete file',
                          style: TextStyle(color: Color(0xFFE31837)),
                        ),
                      ),
                    ],
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.upload_file,
                      color: Color(0xFFE31837),
                    ),
                    onPressed: _pick,
                  ),
        ],
      ),
    );
  }
}
