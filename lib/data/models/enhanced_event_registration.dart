// enhanced_event_registration.dart
import 'package:flutter/material.dart';
import 'event_model.dart';
import 'fighter_model.dart';

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
  
  // Optional related data (populated by repository)
  final Event? event;
  final Fighter? fighterProfile;
  
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
    this.event,
    this.fighterProfile,
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
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
      fighterProfile: json['fighterProfile'] != null ? Fighter.fromJson(json['fighterProfile'] as Map<String, dynamic>) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'fighterId': fighterId,
      'status': _registrationStatusToString(status),
      'weightClass': weightClass,
      'registeredAt': registeredAt.toIso8601String(),
      'coachId': coachId,
      'coachApprovedAt': coachApprovedAt?.toIso8601String(),
      'organizerId': organizerId,
      'organizerApprovedAt': organizerApprovedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'notes': notes,
    };
  }
  
  EnhancedEventRegistration copyWith({
    String? id,
    String? eventId,
    String? fighterId,
    RegistrationStatus? status,
    String? weightClass,
    DateTime? registeredAt,
    String? coachId,
    DateTime? coachApprovedAt,
    String? organizerId,
    DateTime? organizerApprovedAt,
    String? rejectionReason,
    String? notes,
    Event? event,
    Fighter? fighterProfile,
  }) {
    return EnhancedEventRegistration(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      fighterId: fighterId ?? this.fighterId,
      status: status ?? this.status,
      weightClass: weightClass ?? this.weightClass,
      registeredAt: registeredAt ?? this.registeredAt,
      coachId: coachId ?? this.coachId,
      coachApprovedAt: coachApprovedAt ?? this.coachApprovedAt,
      organizerId: organizerId ?? this.organizerId,
      organizerApprovedAt: organizerApprovedAt ?? this.organizerApprovedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
      event: event ?? this.event,
      fighterProfile: fighterProfile ?? this.fighterProfile,
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

String _registrationStatusToString(RegistrationStatus status) {
  switch (status) {
    case RegistrationStatus.approvedByCoach:
      return 'approvedByCoach';
    case RegistrationStatus.approvedByOrganizer:
      return 'approvedByOrganizer';
    case RegistrationStatus.rejected:
      return 'rejected';
    case RegistrationStatus.cancelled:
      return 'cancelled';
    default:
      return 'pending';
  }
}