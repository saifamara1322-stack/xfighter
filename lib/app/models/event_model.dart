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
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'fighterId': fighterId,
      'status': registrationStatusToString(status),
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
  
  String get statusDisplay {
    switch (status) {
      case RegistrationStatus.pending:
        return 'En attente';
      case RegistrationStatus.approvedByCoach:
        return 'Approuvé par coach';
      case RegistrationStatus.approvedByOrganizer:
        return 'Confirmé';
      case RegistrationStatus.rejected:
        return 'Rejeté';
      case RegistrationStatus.cancelled:
        return 'Annulé';
    }
  }
  
  Color get statusColor {
    switch (status) {
      case RegistrationStatus.pending:
        return Colors.orange;
      case RegistrationStatus.approvedByCoach:
        return Colors.blue;
      case RegistrationStatus.approvedByOrganizer:
        return Colors.green;
      case RegistrationStatus.rejected:
        return Colors.red;
      case RegistrationStatus.cancelled:
        return Colors.grey;
    }
  }
  
  static RegistrationStatus _stringToRegistrationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return RegistrationStatus.pending;
      case 'approvedbycoach':
        return RegistrationStatus.approvedByCoach;
      case 'approvedbyorganizer':
        return RegistrationStatus.approvedByOrganizer;
      case 'rejected':
        return RegistrationStatus.rejected;
      case 'cancelled':
        return RegistrationStatus.cancelled;
      default:
        return RegistrationStatus.pending;
    }
  }
  
  static String registrationStatusToString(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.pending:
        return 'pending';
      case RegistrationStatus.approvedByCoach:
        return 'approvedByCoach';
      case RegistrationStatus.approvedByOrganizer:
        return 'approvedByOrganizer';
      case RegistrationStatus.rejected:
        return 'rejected';
      case RegistrationStatus.cancelled:
        return 'cancelled';
    }
  }
}

class EligibilityCheck {
  final bool isEligible;
  final List<String> reasons;
  
  EligibilityCheck({required this.isEligible, required this.reasons});
}

class Event {
  final String id;
  final String name;
  final String description;
  final String organizerId;
  final DateTime date;
  final String location;
  final String city;
  final EventStatus status;
  final List<String> disciplines;
  final List<String> weightClasses;
  final List<FightCard> fightCard;
  final double ticketPrice;
  final int maxFighters;
  final String? posterUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  
  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.organizerId,
    required this.date,
    required this.location,
    required this.city,
    required this.status,
    required this.disciplines,
    required this.weightClasses,
    required this.fightCard,
    required this.ticketPrice,
    required this.maxFighters,
    this.posterUrl,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
    this.approvedBy,
  });
  
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      organizerId: json['organizerId'].toString(),
      date: DateTime.parse(json['date']),
      location: json['location'],
      city: json['city'],
      status: _stringToStatus(json['status']),
      disciplines: List<String>.from(json['disciplines']),
      weightClasses: List<String>.from(json['weightClasses']),
      fightCard: json['fightCard'] != null 
          ? (json['fightCard'] as List).map((f) => FightCard.fromJson(f)).toList()
          : [],
      ticketPrice: (json['ticketPrice'] as num).toDouble(),
      maxFighters: json['maxFighters'],
      posterUrl: json['posterUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      approvedBy: json['approvedBy']?.toString(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'organizerId': organizerId,
      'date': date.toIso8601String(),
      'location': location,
      'city': city,
      'status': statusToString(status),
      'disciplines': disciplines,
      'weightClasses': weightClasses,
      'fightCard': fightCard.map((f) => f.toJson()).toList(),
      'ticketPrice': ticketPrice,
      'maxFighters': maxFighters,
      'posterUrl': posterUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
    };
  }
  
  String get statusDisplay {
    switch (status) {
      case EventStatus.draft:
        return 'Brouillon';
      case EventStatus.pending:
        return 'En attente';
      case EventStatus.approved:
        return 'Approuvé';
      case EventStatus.upcoming:
        return 'À venir';
      case EventStatus.ongoing:
        return 'En cours';
      case EventStatus.completed:
        return 'Terminé';
      case EventStatus.cancelled:
        return 'Annulé';
    }
  }
  
  Color get statusColor {
    switch (status) {
      case EventStatus.draft:
        return Colors.grey;
      case EventStatus.pending:
        return Colors.orange;
      case EventStatus.approved:
        return Colors.blue;
      case EventStatus.upcoming:
        return Colors.green;
      case EventStatus.ongoing:
        return Colors.purple;
      case EventStatus.completed:
        return Colors.teal;
      case EventStatus.cancelled:
        return Colors.red;
    }
  }
  
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  static EventStatus _stringToStatus(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return EventStatus.draft;
      case 'pending':
        return EventStatus.pending;
      case 'approved':
        return EventStatus.approved;
      case 'upcoming':
        return EventStatus.upcoming;
      case 'ongoing':
        return EventStatus.ongoing;
      case 'completed':
        return EventStatus.completed;
      case 'cancelled':
        return EventStatus.cancelled;
      default:
        return EventStatus.draft;
    }
  }
  
  static String statusToString(EventStatus status) {
    return status.name;
  }
}

class FightCard {
  final String id;
  final String fighter1Id;
  final String fighter2Id;
  final String? winnerId;
  final String weightClass;
  final int? round;
  final String? method;
  final String? status;
  
  FightCard({
    required this.id,
    required this.fighter1Id,
    required this.fighter2Id,
    this.winnerId,
    required this.weightClass,
    this.round,
    this.method,
    this.status,
  });
  
  factory FightCard.fromJson(Map<String, dynamic> json) {
    return FightCard(
      id: json['id'].toString(),
      fighter1Id: json['fighter1Id'].toString(),
      fighter2Id: json['fighter2Id'].toString(),
      winnerId: json['winnerId']?.toString(),
      weightClass: json['weightClass'],
      round: json['round'],
      method: json['method'],
      status: json['status'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fighter1Id': fighter1Id,
      'fighter2Id': fighter2Id,
      'winnerId': winnerId,
      'weightClass': weightClass,
      'round': round,
      'method': method,
      'status': status,
    };
  }
}

class EventRegistration {
  final String id;
  final String eventId;
  final String fighterId;
  final String status;
  final String weightClass;
  final DateTime registeredAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  
  EventRegistration({
    required this.id,
    required this.eventId,
    required this.fighterId,
    required this.status,
    required this.weightClass,
    required this.registeredAt,
    this.approvedBy,
    this.approvedAt,
  });
  
  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      id: json['id'].toString(),
      eventId: json['eventId'].toString(),
      fighterId: json['fighterId'].toString(),
      status: json['status'],
      weightClass: json['weightClass'],
      registeredAt: DateTime.parse(json['registeredAt']),
      approvedBy: json['approvedBy']?.toString(),
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'fighterId': fighterId,
      'status': status,
      'weightClass': weightClass,
      'registeredAt': registeredAt.toIso8601String(),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
    };
  }
}