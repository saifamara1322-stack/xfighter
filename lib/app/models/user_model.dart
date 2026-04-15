import 'package:flutter/material.dart';

enum UserRole {
  fighter,
  coach,
  organizer,
  referee,
  admin;

  static String roleToString(UserRole value) {
    return value.name;
  }
  
  static UserRole stringToRole(String? value) {
    if (value == null) return UserRole.fighter;
    switch (value.toLowerCase()) {
      case 'fighter':
        return UserRole.fighter;
      case 'coach':
        return UserRole.coach;
      case 'organizer':
        return UserRole.organizer;
      case 'referee':
        return UserRole.referee;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.fighter;
    }
  }
}

enum UserStatus {
  active,
  pending,
  suspended;

  static String statusToString(UserStatus value) {
    return value.name;
  }
  
  static UserStatus stringToStatus(String? value) {
    if (value == null) return UserStatus.pending;
    switch (value.toLowerCase()) {
      case 'active':
        return UserStatus.active;
      case 'pending':
        return UserStatus.pending;
      case 'suspended':
        return UserStatus.suspended;
      default:
        return UserStatus.pending;
    }
  }
}

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final UserStatus status;
  final bool verified;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.status,
    required this.verified,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      role: UserRole.stringToRole(json['role']?.toString()),
      status: UserStatus.stringToStatus(json['status']?.toString()),
      verified: json['verified'] ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': UserRole.roleToString(role),
      'status': UserStatus.statusToString(status),
      'verified': verified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
  
  String get fullName => '$firstName $lastName';
  bool get isActive => status == UserStatus.active;
  bool get isPending => status == UserStatus.pending;
  bool get isSuspended => status == UserStatus.suspended;
  
  String get roleDisplay {
    switch (role) {
      case UserRole.fighter:
        return 'Fighter';
      case UserRole.coach:
        return 'Coach';
      case UserRole.organizer:
        return 'Organizer';
      case UserRole.referee:
        return 'Referee';
      case UserRole.admin:
        return 'Administrator';
    }
  }
  
  String get statusDisplay {
    switch (status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.pending:
        return 'Pending';
      case UserStatus.suspended:
        return 'Suspended';
    }
  }
  
  Color get statusColor {
    switch (status) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.pending:
        return Colors.orange;
      case UserStatus.suspended:
        return Colors.red;
    }
  }
  
  IconData get roleIcon {
    switch (role) {
      case UserRole.fighter:
        return Icons.sports_mma;
      case UserRole.coach:
        return Icons.school;
      case UserRole.organizer:
        return Icons.event;
      case UserRole.referee:
        return Icons.gavel;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }
}