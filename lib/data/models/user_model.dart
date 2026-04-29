import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum UserRole {
  SUPER_ADMIN,
  ADMIN,
  ORGANIZER,
  CLUB,
  COACH,
  FIGHTER,
  REFEREE,
  USER;

  static UserRole fromString(String? value) {
    if (value == null) return UserRole.USER;
    try {
      return UserRole.values.firstWhere(
        (e) => e.name == value.toUpperCase(),
        orElse: () => UserRole.USER,
      );
    } catch (_) {
      return UserRole.USER;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.SUPER_ADMIN:
        return 'Super Admin';
      case UserRole.ADMIN:
        return 'Admin';
      case UserRole.ORGANIZER:
        return 'Organizer';
      case UserRole.CLUB:
        return 'Club';
      case UserRole.COACH:
        return 'Coach';
      case UserRole.FIGHTER:
        return 'Fighter';
      case UserRole.REFEREE:
        return 'Referee';
      case UserRole.USER:
        return 'User';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.SUPER_ADMIN:
        return const Color(0xFF9C27B0);
      case UserRole.ADMIN:
        return const Color(0xFF3F51B5);
      case UserRole.ORGANIZER:
        return const Color(0xFF009688);
      case UserRole.CLUB:
        return const Color(0xFF795548);
      case UserRole.COACH:
        return const Color(0xFF2196F3);
      case UserRole.FIGHTER:
        return const Color(0xFFF44336);
      case UserRole.REFEREE:
        return const Color(0xFFFF9800);
      case UserRole.USER:
        return const Color(0xFF607D8B);
    }
  }

  // Legacy helper used by auth_controller
  static String roleToString(UserRole value) => value.name;
  static UserRole stringToRole(String? value) => fromString(value);
}

enum UserStatus {
  NODOCS,
  PENDING,
  ACTIVE,
  REFUSED,
  DISABLED;

  static UserStatus fromString(String? value) {
    if (value == null) return UserStatus.PENDING;
    try {
      return UserStatus.values.firstWhere(
        (e) => e.name == value.toUpperCase(),
        orElse: () => UserStatus.PENDING,
      );
    } catch (_) {
      return UserStatus.PENDING;
    }
  }

  // Legacy helpers
  static String statusToString(UserStatus value) => value.name;
  static UserStatus stringToStatus(String? value) => fromString(value);

  String get displayName {
    switch (this) {
      case UserStatus.NODOCS:
        return 'No Documents';
      case UserStatus.PENDING:
        return 'Pending';
      case UserStatus.ACTIVE:
        return 'Active';
      case UserStatus.REFUSED:
        return 'Refused';
      case UserStatus.DISABLED:
        return 'Disabled';
    }
  }

  Color get color {
    switch (this) {
      case UserStatus.NODOCS:
        return Colors.grey;
      case UserStatus.PENDING:
        return Colors.orange;
      case UserStatus.ACTIVE:
        return Colors.green;
      case UserStatus.REFUSED:
        return Colors.red;
      case UserStatus.DISABLED:
        return Colors.blueGrey;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UserDTO  (matches API #/components/schemas/UserDTO)
// ─────────────────────────────────────────────────────────────────────────────

class User {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final UserRole role;
  final UserStatus status;
  final String? countryId;
  final String? createdById;
  final String? verifiedById;
  final DateTime? verifiedAt;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.status,
    this.phoneNumber,
    this.countryId,
    this.createdById,
    this.verifiedById,
    this.verifiedAt,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'],
      role: UserRole.fromString(json['role']),
      status: UserStatus.fromString(json['status']),
      countryId: json['countryId']?.toString(),
      createdById: json['createdById']?.toString(),
      verifiedById: json['verifiedById']?.toString(),
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'role': role.name,
        'status': status.name,
        'countryId': countryId,
        'createdById': createdById,
        'verifiedById': verifiedById,
        'verifiedAt': verifiedAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
      };

  /// Convenience getter kept for views that still reference it
  String get firstName => fullName.split(' ').first;
  String get lastName =>
      fullName.contains(' ') ? fullName.split(' ').skip(1).join(' ') : '';
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthResponse  (matches API #/components/schemas/AuthResponse)
// ─────────────────────────────────────────────────────────────────────────────

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserRole role;
  final String userId;
  final UserStatus status;
  final String? message;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.userId,
    required this.status,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      role: UserRole.fromString(json['role']),
      userId: json['userId']?.toString() ?? '',
      status: UserStatus.fromString(json['status']),
      message: json['message'],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic paged response wrapper
// ─────────────────────────────────────────────────────────────────────────────

class PagedResponse<T> {
  final List<T> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  const PagedResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rawContent = json['content'] as List<dynamic>? ?? [];
    return PagedResponse<T>(
      content: rawContent
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
      pageNumber: json['pageNumber'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic API response envelope
// ─────────────────────────────────────────────────────────────────────────────

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  const ApiResponse({required this.success, this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(dynamic) fromData,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: fromData(json['data']),
    );
  }
}