// ─────────────────────────────────────────────────────────────────────────────
// Admin Models  (matches API /api/admin/* schemas)
// ─────────────────────────────────────────────────────────────────────────────

// ── CreateAdminRequest ────────────────────────────────────────────────────────

class CreateAdminRequest {
  final String email;
  final String password;
  final String? fullName;
  final String? phoneNumber;
  final String? city;
  final String countryId;

  const CreateAdminRequest({
    required this.email,
    required this.password,
    required this.countryId,
    this.fullName,
    this.phoneNumber,
    this.city,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'countryId': countryId,
        if (fullName != null) 'fullName': fullName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (city != null) 'city': city,
      };
}

// ── UpdateAdminRequest ────────────────────────────────────────────────────────

class UpdateAdminRequest {
  final String? email;
  final String? password;
  final String? fullName;
  final String? phoneNumber;
  final String? city;
  final String? countryId;

  const UpdateAdminRequest({
    this.email,
    this.password,
    this.fullName,
    this.phoneNumber,
    this.city,
    this.countryId,
  });

  Map<String, dynamic> toJson() => {
        if (email != null) 'email': email,
        if (password != null) 'password': password,
        if (fullName != null) 'fullName': fullName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (city != null) 'city': city,
        if (countryId != null) 'countryId': countryId,
      };
}

// ── ChangeEmailRequest ────────────────────────────────────────────────────────

class ChangeEmailRequest {
  final String newEmail;

  const ChangeEmailRequest({required this.newEmail});

  Map<String, dynamic> toJson() => {'newEmail': newEmail};
}

// ── ChangePasswordRequest ─────────────────────────────────────────────────────

class ChangePasswordRequest {
  final String? oldPassword;
  final String newPassword;

  const ChangePasswordRequest({
    required this.newPassword,
    this.oldPassword,
  });

  Map<String, dynamic> toJson() => {
        if (oldPassword != null) 'oldPassword': oldPassword,
        'newPassword': newPassword,
      };
}

// ── AdminAuditResponse ────────────────────────────────────────────────────────

class AdminAuditResponse {
  final String id;
  final String email;
  final String fullName;
  final String status;
  final String? createdById;
  final String? createdByEmail;
  final String? verifiedById;
  final String? verifiedByEmail;
  final String? updatedById;
  final String? updatedByEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? verifiedAt;
  final DateTime? lastLoginAt;

  const AdminAuditResponse({
    required this.id,
    required this.email,
    required this.fullName,
    required this.status,
    this.createdById,
    this.createdByEmail,
    this.verifiedById,
    this.verifiedByEmail,
    this.updatedById,
    this.updatedByEmail,
    this.createdAt,
    this.updatedAt,
    this.verifiedAt,
    this.lastLoginAt,
  });

  factory AdminAuditResponse.fromJson(Map<String, dynamic> json) =>
      AdminAuditResponse(
        id: json['id']?.toString() ?? '',
        email: json['email'] ?? '',
        fullName: json['fullName'] ?? '',
        status: json['status'] ?? '',
        createdById: json['createdById']?.toString(),
        createdByEmail: json['createdByEmail'],
        verifiedById: json['verifiedById']?.toString(),
        verifiedByEmail: json['verifiedByEmail'],
        updatedById: json['updatedById']?.toString(),
        updatedByEmail: json['updatedByEmail'],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : null,
        verifiedAt: json['verifiedAt'] != null
            ? DateTime.tryParse(json['verifiedAt'])
            : null,
        lastLoginAt: json['lastLoginAt'] != null
            ? DateTime.tryParse(json['lastLoginAt'])
            : null,
      );
}
