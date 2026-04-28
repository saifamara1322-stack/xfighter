import 'package:flutter/material.dart';

enum GymStatus {
  pending,
  active,
  suspended,
  rejected;
  
  static GymStatus fromString(String? value) {
    if (value == null) return GymStatus.pending;
    switch (value.toLowerCase()) {
      case 'active':
        return GymStatus.active;
      case 'suspended':
        return GymStatus.suspended;
      case 'rejected':
        return GymStatus.rejected;
      default:
        return GymStatus.pending;
    }
  }
  
  String get string {
    return name;
  }
  
  String get display {
    return name[0].toUpperCase() + name.substring(1);
  }
  
  Color get color {
    switch (this) {
      case GymStatus.pending:
        return Colors.orange;
      case GymStatus.active:
        return Colors.green;
      case GymStatus.suspended:
        return Colors.red;
      case GymStatus.rejected:
        return Colors.grey;
    }
  }
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
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      ownerId: json['ownerId']?.toString(),
      status: GymStatus.fromString(json['status']),
      verified: json['verified'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
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
      'status': status.name,
      'verified': verified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'logoUrl': logoUrl,
      'description': description,
      'fighters': fighters,
    };
  }
  
  String get statusDisplayName {
    switch (status) {
      case GymStatus.pending:
        return 'Pending';
      case GymStatus.active:
        return 'Active';
      case GymStatus.suspended:
        return 'Suspended';
      case GymStatus.rejected:
        return 'Rejected';
    }
  }
}