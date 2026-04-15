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
    return {
      'id': id,
      'userId': userId,
      'certifications': certifications,
      'specialization': specialization,
      'experience': experience,
      'gym': gym,
      'verified': verified,
      'status': statusToString(status),
      'fighters': fighters,
      'bio': bio,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  String get statusDisplay {
    switch (status) {
      case CoachStatus.active:
        return 'Actif';
      case CoachStatus.pending:
        return 'En attente';
      case CoachStatus.suspended:
        return 'Suspendu';
    }
  }
  
  Color get statusColor {
    switch (status) {
      case CoachStatus.active:
        return Colors.green;
      case CoachStatus.pending:
        return Colors.orange;
      case CoachStatus.suspended:
        return Colors.red;
    }
  }
  
  String get experienceDisplay {
    if (experience == 0) return 'Débutant';
    if (experience == 1) return '1 an d\'expérience';
    return '$experience ans d\'expérience';
  }
  
  static CoachStatus _stringToStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return CoachStatus.active;
      case 'pending':
        return CoachStatus.pending;
      case 'suspended':
        return CoachStatus.suspended;
      default:
        return CoachStatus.pending;
    }
  }
  
  static String statusToString(CoachStatus status) {
    return status.name;
  }
}

class Certification {
  final String id;
  final String name;
  final String issuingBody;
  final int yearObtained;
  final String? documentUrl;
  
  Certification({
    required this.id,
    required this.name,
    required this.issuingBody,
    required this.yearObtained,
    this.documentUrl,
  });
  
  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      id: json['id'].toString(),
      name: json['name'],
      issuingBody: json['issuingBody'],
      yearObtained: json['yearObtained'],
      documentUrl: json['documentUrl'],
    );
  }
}