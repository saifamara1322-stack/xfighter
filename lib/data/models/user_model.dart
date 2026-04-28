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
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: UserRole.stringToRole(json['role']),
      status: UserStatus.stringToStatus(json['status']),
      verified: json['verified'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
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
  
  String get fullName => '$firstName $lastName';
  
  String get roleDisplayName {
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
        return 'Admin';
    }
  }
}