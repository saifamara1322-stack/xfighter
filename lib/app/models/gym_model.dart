import 'package:flutter/material.dart';

enum GymStatus {
  pending,
  active,
  suspended,
  rejected,
}

class Gym {
  final String id;
  final String name;
  final String address;
  final String city;
  final String phone;
  final String email;
  final String? ownerId;
  final GymStatus status;
  final bool verified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? logoUrl;
  final String? description;
  final List<String> fighters;
  
  Gym({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.email,
    this.ownerId,
    required this.status,
    required this.verified,
    required this.createdAt,
    required this.updatedAt,
    this.logoUrl,
    this.description,
    this.fighters = const [],
  });
  
  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      id: json['id'].toString(),
      name: json['name'],
      address: json['address'],
      city: json['city'],
      phone: json['phone'],
      email: json['email'],
      ownerId: json['ownerId']?.toString(),
      status: _stringToStatus(json['status']),
      verified: json['verified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      logoUrl: json['logoUrl'],
      description: json['description'],
      fighters: json['fighters'] != null ? List<String>.from(json['fighters']) : [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'phone': phone,
      'email': email,
      'ownerId': ownerId,
      'status': statusToString(status),
      'verified': verified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'logoUrl': logoUrl,
      'description': description,
      'fighters': fighters,
    };
  }
  
  String get statusDisplay {
    switch (status) {
      case GymStatus.active:
        return 'Active';
      case GymStatus.pending:
        return 'En attente';
      case GymStatus.suspended:
        return 'Suspendue';
      case GymStatus.rejected:
        return 'Rejetée';
    }
  }
  
  Color get statusColor {
    switch (status) {
      case GymStatus.active:
        return Colors.green;
      case GymStatus.pending:
        return Colors.orange;
      case GymStatus.suspended:
        return Colors.red;
      case GymStatus.rejected:
        return Colors.grey;
    }
  }
  
  static GymStatus _stringToStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return GymStatus.active;
      case 'pending':
        return GymStatus.pending;
      case 'suspended':
        return GymStatus.suspended;
      case 'rejected':
        return GymStatus.rejected;
      default:
        return GymStatus.pending;
    }
  }
  
  static String statusToString(GymStatus status) {
    return status.name;
  }
}

class GymRegistrationRequest {
  final String id;
  final String gymId;
  final String requesterId;
  final String status;
  final DateTime submittedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? comments;
  
  GymRegistrationRequest({
    required this.id,
    required this.gymId,
    required this.requesterId,
    required this.status,
    required this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.comments,
  });
  
  factory GymRegistrationRequest.fromJson(Map<String, dynamic> json) {
    return GymRegistrationRequest(
      id: json['id'].toString(),
      gymId: json['gymId'].toString(),
      requesterId: json['requesterId'].toString(),
      status: json['status'],
      submittedAt: DateTime.parse(json['submittedAt']),
      reviewedBy: json['reviewedBy']?.toString(),
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      comments: json['comments'],
    );
  }
}