import 'package:flutter/material.dart';

enum EventStatus {
  draft,
  pending,
  approved,
  upcoming,
  ongoing,
  completed,
  cancelled,
}

enum RegistrationStatus {
  pending,
  approvedByCoach,
  approvedByOrganizer,
  rejected,
  cancelled,
}

class EnhancedEventRegistration {
  final String id;
  final String eventId;
  final String fighterId;
  final RegistrationStatus status;
  final String weightClass;
  final DateTime registeredAt;
  final String? coachId;
  final DateTime? coachApprovedAt;
  final String? organizerId;
  final DateTime? organizerApprovedAt;
  final String? rejectionReason;
  final String? notes;
  
  EnhancedEventRegistration({
    required this.id,
    required this.eventId,
    required this.fighterId,
    required this.status,
    required this.weightClass,
    required this.registeredAt,
    this.coachId,
    this.coachApprovedAt,
    this.organizerId,
    this.organizerApprovedAt,
    this.rejectionReason,
    this.notes,
  });
  
  factory EnhancedEventRegistration.fromJson(Map<String, dynamic> json) {
    return EnhancedEventRegistration(
      id: json['id'].toString(),
      eventId: json['eventId'].toString(),
      fighterId: json['fighterId'].toString(),
      status: _stringToRegistrationStatus(json['status']),
      weightClass: json['weightClass'],
      registeredAt: DateTime.parse(json['registeredAt']),
      coachId: json['coachId']?.toString(),
      coachApprovedAt: json['coachApprovedAt'] != null ? DateTime.parse(json['coachApprovedAt']) : null,
      organizerId: json['organizerId']?.toString(),
      organizerApprovedAt: json['organizerApprovedAt'] != null ? DateTime.parse(json['organizerApprovedAt']) : null,
      rejectionReason: json['rejectionReason'],
      notes: json['notes'],
    );
  }
}
RegistrationStatus _stringToRegistrationStatus(String status) {
  switch (status) {
    case 'approvedByCoach':
      return RegistrationStatus.approvedByCoach;
    case 'approvedByOrganizer':
      return RegistrationStatus.approvedByOrganizer;
    case 'rejected':
      return RegistrationStatus.rejected;
    case 'cancelled':
      return RegistrationStatus.cancelled;
    default:
      return RegistrationStatus.pending;
  }
}
