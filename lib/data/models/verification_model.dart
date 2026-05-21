// ─────────────────────────────────────────────────────────────────────────────
// Verification Models  (matches API /api/verification/* schemas)
// ─────────────────────────────────────────────────────────────────────────────

// ── UserDocumentsResponse ─────────────────────────────────────────────────────

class UserDocumentsResponse {
  final String userId;
  final String fullName;
  final String email;
  final String role;
  final String status;
  final String? idCardUrl;
  final String? profileImageUrl;
  final String? medicalCertificateUrl;
  final String? federalLicenseUrl;
  final String? licenseUrl;
  final String? rejectionNote;

  const UserDocumentsResponse({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    this.idCardUrl,
    this.profileImageUrl,
    this.medicalCertificateUrl,
    this.federalLicenseUrl,
    this.licenseUrl,
    this.rejectionNote,
  });

  factory UserDocumentsResponse.fromJson(Map<String, dynamic> json) =>
      UserDocumentsResponse(
        userId: json['userId']?.toString() ?? '',
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? '',
        status: json['status'] ?? '',
        idCardUrl: json['idCardUrl'],
        profileImageUrl: json['profileImageUrl'],
        medicalCertificateUrl: json['medicalCertificateUrl'],
        federalLicenseUrl: json['federalLicenseUrl'],
        licenseUrl: json['licenseUrl'],
        rejectionNote: json['rejectionNote'],
      );

  /// Returns a map of document label → URL for non-null documents
  Map<String, String> get documentUrls {
    final m = <String, String>{};
    if (idCardUrl != null) m['ID Card'] = idCardUrl!;
    if (profileImageUrl != null) m['Profile Image'] = profileImageUrl!;
    if (medicalCertificateUrl != null) m['Medical Certificate'] = medicalCertificateUrl!;
    if (federalLicenseUrl != null) m['Federal License'] = federalLicenseUrl!;
    if (licenseUrl != null) m['License'] = licenseUrl!;
    return m;
  }
}

// ── RejectionRequest ──────────────────────────────────────────────────────────

class RejectionRequest {
  final String reason;

  const RejectionRequest({required this.reason});

  Map<String, dynamic> toJson() => {'reason': reason};
}

// ── PendingUserPage (wrapper for the raw User page returned by verification endpoints) ──

class PendingUserPage {
  final int totalElements;
  final int totalPages;
  final int size;
  final List<Map<String, dynamic>> content;
  final int number;
  final bool first;
  final bool last;
  final bool empty;

  const PendingUserPage({
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.content,
    required this.number,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory PendingUserPage.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'] as List<dynamic>? ?? [];
    return PendingUserPage(
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      size: json['size'] ?? 0,
      content: rawContent
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      number: json['number'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      empty: json['empty'] ?? true,
    );
  }
}
