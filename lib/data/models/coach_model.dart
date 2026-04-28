import 'package:flutter/material.dart';

enum CoachStatus {
  pending,
  active,
  suspended,
}

class Coach {
  final String id;
  final String userId;
  final List<String> certifications;
  final String specialization;
  final int experience;
  final String? gym;
  final bool verified;
  final CoachStatus status;
  final List<String> fighters;
  final String? bio;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Coach({
    required this.id,
    required this.userId,
    required this.certifications,
    required this.specialization,
    required this.experience,
    this.gym,
    required this.verified,
    required this.status,
    this.fighters = const [],
    this.bio,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      certifications: json['certifications'] != null 
          ? List<String>.from(json['certifications']) 
          : [],
      specialization: json['specialization'],
      experience: json['experience'],
      gym: json['gym'],
      verified: json['verified'] ?? false,
      status: _stringToStatus(json['status'] ?? 'pending'),
      fighters: json['fighters'] != null ? List<String>.from(json['fighters']) : [],
      bio: json['bio'],
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    // ...existing code...
    return {};
  }
}
CoachStatus _stringToStatus(String status) {
  switch (status) {
    case 'active':
      return CoachStatus.active;
    case 'suspended':
      return CoachStatus.suspended;
    default:
      return CoachStatus.pending;
  }
}
