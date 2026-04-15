import 'package:flutter/material.dart';

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
  String? profileImage;
  String? phoneNumber;
  
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
    this.profileImage,
    this.phoneNumber,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: UserRoleExtension.fromString(json['role']),
      status: UserStatusExtension.fromString(json['status']),
      verified: json['verified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      profileImage: json['profileImage'],
      phoneNumber: json['phoneNumber'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.name,
      'status': status.name,
      'verified': verified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
    };
  }
  
  String get fullName => '$firstName $lastName';
  bool get isActive => status == UserStatus.active;
  bool get isPending => status == UserStatus.pending;
  bool get isSuspended => status == UserStatus.suspended;
}

enum UserRole {
  fighter,
  coach,
  organizer,
  referee,
  admin,
}

enum UserStatus {
  active,
  pending,
  suspended,
}

class UserRoleExtension {
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
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
  
  static String getRoleName(UserRole role) {
    return role.name;
  }
  
  static IconData getIcon(UserRole role) {
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
  
  static String getDisplayName(UserRole role) {
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
}

class UserStatusExtension {
  static UserStatus fromString(String status) {
    switch (status.toLowerCase()) {
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
  
  static Color getColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.pending:
        return Colors.orange;
      case UserStatus.suspended:
        return Colors.red;
    }
  }
  
  static String getDisplayName(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.pending:
        return 'Pending Verification';
      case UserStatus.suspended:
        return 'Suspended';
    }
  }
}

class LoginRequest {
  final String email;
  final String password;
  
  LoginRequest({required this.email, required this.password});
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? phoneNumber;
  
  RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phoneNumber,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.name,
      'phoneNumber': phoneNumber,
    };
  }
}

class AuthResponse {
  final bool success;
  final String? token;
  final User? user;
  final String? message;
  
  AuthResponse({
    required this.success,
    this.token,
    this.user,
    this.message,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      message: json['message'],
    );
  }
}